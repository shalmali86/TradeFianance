/*
 * SPDX-License-Identifier: Apache-2.0
 */

"use strict";

const { Gateway, Wallets } = require("fabric-network");
const path = require("path");
const fs = require("fs");

async function query(fcn, args) {
  try {
    // Create a new file system based wallet for managing identities.
    // Create a new file system based wallet for managing identities.
    console.log(fcn, args);
    const ccpPath = path.resolve(
      __dirname,
      "..",
      "hlf-network",
      "organizations",
      "peerOrganizations",
      "buyer.example.com",
      "connection-buyer.json"
    );
    let ccp = JSON.parse(fs.readFileSync(ccpPath, "utf8"));

    // Create a new file system based wallet for managing identities.
    const walletPath = path.join(process.cwd(), "wallet");
    const wallet = await Wallets.newFileSystemWallet(walletPath);
    console.log(`Wallet path: ${walletPath}`);

    // Check to see if we've already enrolled the user.
    const userExists = await wallet.get("BuyerUser");
    if (!userExists) {
      console.log(
        'An identity for the user "BuyerUser" does not exist in the wallet'
      );
      console.log("Run the registerUser.js application before retrying");
      return;
    }

    // Create a new gateway for connecting to our peer node.
    const gateway = new Gateway();
    await gateway.connect(ccp, {
      wallet,
      identity: "BuyerUser",
      discovery: { enabled: true, asLocalhost: true },
    });

    // Get the network (channel) our contract is deployed to.
    const network = await gateway.getNetwork("mychannel");

    // Get the contract from the network.
    const contract = network.getContract("tfbc");
    // Evaluate the specified transaction.
    // queryCar transaction - requires 1 argument, ex: ('queryCar', 'CAR4')
    // queryAllCars transaction - requires no arguments, ex: ('queryAllCars')
    const result = await contract.evaluateTransaction(fcn, args);
    console.log(
      `Transaction has been evaluated, result is: ${result.toString()}`
    );
    return result;
  } catch (error) {
    console.error(`Failed to evaluate transaction: ${error}`);
    throw err;
  }
}

exports.query = query;
