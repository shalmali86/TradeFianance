/*
 * SPDX-License-Identifier: Apache-2.0
 */

"use strict";

const { Wallets } = require("fabric-network");
const FabricCAServices = require("fabric-ca-client");
const path = require("path");
const fs = require("fs");

async function main() {
  try {
    // load the network configuration
    const ccpPath = path.resolve(
      __dirname,
      "..",
      "hlf-network",
      "organizations",
      "peerOrganizations",
      "seller.example.com",
      "connection-seller.json"
    );
    const ccp = JSON.parse(fs.readFileSync(ccpPath, "utf8"));

    // Create a new CA client for interacting with the CA.
    const caURL = ccp.certificateAuthorities["ca.seller.example.com"].url;
    const ca = new FabricCAServices(caURL);

    // Create a new file system based wallet for managing identities.
    const walletPath = path.join(process.cwd(), "wallet");
    const wallet = await Wallets.newFileSystemWallet(walletPath);
    console.log(`Wallet path: ${walletPath}`);
    // Check to see if we've already enrolled the user.
    const userExists = await wallet.get("sellerUser");
    if (userExists) {
      console.log(
        'An identity for the user "sellerUser" already exists in the wallet'
      );
      return;
    }

    // Check to see if we've already enrolled the admin user.
    const adminExists = await wallet.get("admin-seller");
    if (!adminExists) {
      const caInfo = ccp.certificateAuthorities["ca.seller.example.com"];
      console.log(caInfo);
      //const caTLSCACerts = caInfo.tlsCACerts.pem;
      const caTLSCACerts = caInfo.tlsCACerts.pem;
      const ca = new FabricCAServices(
        caInfo.url,
        { trustedRoots: caTLSCACerts, verify: false },
        caInfo.caName
      );
      // Enroll the admin user, and import the new identity into the wallet.
      const enrollment = await ca.enroll({
        enrollmentID: "admin",
        enrollmentSecret: "adminpw",
      });
      const x509Identity = {
        credentials: {
          certificate: enrollment.certificate,
          privateKey: enrollment.key.toBytes(),
        },
        mspId: "sellerMSP",
        type: "X.509",
      };
      await wallet.put("admin-seller", x509Identity);
      main();
      return;
    }

    // // Create a new gateway for connecting to our peer node.
    // const gateway = new Gateway();
    // await gateway.connect(ccpPath, {
    //   wallet,
    //   identity: "admin-seller",
    //   discovery: { enabled: true, asLocalhost: true },
    // });

    // Get the CA client object from the gateway for interacting with the CA.
    const provider = wallet.getProviderRegistry().getProvider(adminExists.type);
    const adminUser = await provider.getUserContext(
      adminExists,
      "admin-seller"
    );

    // Register the user, enroll the user, and import the new identity into the wallet.
    const secret = await ca.register(
      { enrollmentID: "sellerUser", role: "client" },
      adminUser
    );
    const enrollment = await ca.enroll({
      enrollmentID: "sellerUser",
      enrollmentSecret: secret,
    });
    const x509Identity = {
      credentials: {
        certificate: enrollment.certificate,
        privateKey: enrollment.key.toBytes(),
      },
      mspId: "sellerMSP",
      type: "X.509",
    };
    await wallet.put("sellerUser", x509Identity);
    console.log(
      'Successfully registered and enrolled admin user "sellerUser" and imported it into the wallet'
    );
  } catch (error) {
    console.error(`Failed to register user "sellerUser": ${error}`);
    process.exit(1);
  }
}

main();
