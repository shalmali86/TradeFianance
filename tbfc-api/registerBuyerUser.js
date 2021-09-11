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
      "buyer.example.com",
      "connection-buyer.json"
    );
    const ccp = JSON.parse(fs.readFileSync(ccpPath, "utf8"));

    // Create a new CA client for interacting with the CA.
    const caURL = ccp.certificateAuthorities["ca.buyer.example.com"].url;
    const ca = new FabricCAServices(caURL);

    // Create a new file system based wallet for managing identities.
    const walletPath = path.join(process.cwd(), "wallet");
    const wallet = await Wallets.newFileSystemWallet(walletPath);
    console.log(`Wallet path: ${walletPath}`);
    // Check to see if we've already enrolled the user.
    const userExists = await wallet.get("BuyerUser");
    if (userExists) {
      console.log(
        'An identity for the user "BuyerUser" already exists in the wallet'
      );
      return;
    }

    // Check to see if we've already enrolled the admin user.
    const adminExists = await wallet.get("admin-buyer");
    if (!adminExists) {
      const caInfo = ccp.certificateAuthorities["ca.buyer.example.com"];
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
        mspId: "buyerMSP",
        type: "X.509",
      };
      await wallet.put("admin-buyer", x509Identity);
      main();
      return;
    }

    // // Create a new gateway for connecting to our peer node.
    // const gateway = new Gateway();
    // await gateway.connect(ccpPath, {
    //   wallet,
    //   identity: "admin-buyer",
    //   discovery: { enabled: true, asLocalhost: true },
    // });

    // Get the CA client object from the gateway for interacting with the CA.
    const provider = wallet.getProviderRegistry().getProvider(adminExists.type);
    const adminUser = await provider.getUserContext(adminExists, "admin-buyer");

    // Register the user, enroll the user, and import the new identity into the wallet.
    const secret = await ca.register(
      { enrollmentID: "BuyerUser", role: "client" },
      adminUser
    );
    const enrollment = await ca.enroll({
      enrollmentID: "BuyerUser",
      enrollmentSecret: secret,
    });
    const x509Identity = {
      credentials: {
        certificate: enrollment.certificate,
        privateKey: enrollment.key.toBytes(),
      },
      mspId: "buyerMSP",
      type: "X.509",
    };
    await wallet.put("BuyerUser", x509Identity);
    console.log(
      'Successfully registered and enrolled admin user "BuyerUser" and imported it into the wallet'
    );
  } catch (error) {
    console.error(`Failed to register user "BuyerUser": ${error}`);
    process.exit(1);
  }
}

main();
