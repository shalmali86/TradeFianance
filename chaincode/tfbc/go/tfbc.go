/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

/*
 * The sample smart contract for documentation topic:
 * Trade Finance Use Case - WORK IN  PROGRESS
 */

package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"strconv"
	"time"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

func main() {

	// instantiate chaincode
	tfbcChaincode := initTfbcChaincode()
	chaincode, err := contractapi.NewChaincode(tfbcChaincode)
	if err != nil {
		fmt.Printf("failed to create chaincode: %v", err)
		return
	}

	// run chaincode
	err = chaincode.Start()
	fmt.Printf("***********New Chaincode Started***********")
	if err != nil {
		fmt.Printf("failed to start chaincode: %v", err)
	}
}

// TfbcChaincode creates a new hlf contract api
type TfbcChaincode struct {
	contractapi.Contract
}

var contract *TfbcChaincode

func initTfbcChaincode() *TfbcChaincode {
	if contract != nil {
		return contract
	}

	var newContract = TfbcChaincode{}
	contract = &newContract

	return contract
}

// Define the letter of credit
type LetterOfCredit struct {
	LCId       string `json:"lcId"`
	ExpiryDate string `json:"expiryDate"`
	Buyer      string `json:"buyer"`
	Bank       string `json:"bank"`
	Seller     string `json:"seller"`
	Amount     int    `json:"amount,int"`
	Status     string `json:"status"`
}

func (s *TfbcChaincode) Init(APIstub contractapi.TransactionContextInterface) error {
	return nil
}

// This function is initiate by Buyer
func (s *TfbcChaincode) RequestLC(APIstub contractapi.TransactionContextInterface, args string) error {

	LC := LetterOfCredit{}

	err := json.Unmarshal([]byte(args), &LC)
	if err != nil {
		return fmt.Errorf("Not able to parse args into LC")
	}
	LCBytes, err := json.Marshal(LC)
	APIstub.GetStub().PutState(LC.LCId, LCBytes)
	fmt.Println("LC Requested -> ", LC)

	return nil
}

// This function is initiate by Seller
func (s *TfbcChaincode) IssueLC(APIstub contractapi.TransactionContextInterface, args string) error {

	lcID := struct {
		LcID string `json:"lcID"`
	}{}
	err := json.Unmarshal([]byte(args), &lcID)
	if err != nil {
		return fmt.Errorf("Not able to parse args into LCID")
	}

	// if err != nil {
	// 	return fmt.Errorf("No Amount")
	// }

	LCAsBytes, _ := APIstub.GetStub().GetState(lcID.LcID)

	var lc LetterOfCredit

	err = json.Unmarshal(LCAsBytes, &lc)

	if err != nil {
		return fmt.Errorf("Issue with LC json unmarshaling")
	}

	LC := LetterOfCredit{LCId: lc.LCId, ExpiryDate: lc.ExpiryDate, Buyer: lc.Buyer, Bank: lc.Bank, Seller: lc.Seller, Amount: lc.Amount, Status: "Issued"}
	LCBytes, err := json.Marshal(LC)

	if err != nil {
		return fmt.Errorf("Issue with LC json marshaling")
	}

	APIstub.GetStub().PutState(lc.LCId, LCBytes)
	fmt.Println("LC Issued -> ", LC)

	return nil
}

func (s *TfbcChaincode) AcceptLC(APIstub contractapi.TransactionContextInterface, args string) error {

	lcID := struct {
		LcID string `json:"lcID"`
	}{}
	err := json.Unmarshal([]byte(args), &lcID)
	if err != nil {
		return fmt.Errorf("Not able to parse args into LC")
	}

	LCAsBytes, _ := APIstub.GetStub().GetState(lcID.LcID)

	var lc LetterOfCredit

	err = json.Unmarshal(LCAsBytes, &lc)

	if err != nil {
		return fmt.Errorf("Issue with LC json unmarshaling")
	}

	LC := LetterOfCredit{LCId: lc.LCId, ExpiryDate: lc.ExpiryDate, Buyer: lc.Buyer, Bank: lc.Bank, Seller: lc.Seller, Amount: lc.Amount, Status: "Accepted"}
	LCBytes, err := json.Marshal(LC)

	if err != nil {
		return fmt.Errorf("Issue with LC json marshaling")
	}

	APIstub.GetStub().PutState(lc.LCId, LCBytes)
	fmt.Println("LC Accepted -> ", LC)

	return nil
}

func (s *TfbcChaincode) GetLC(APIstub contractapi.TransactionContextInterface, args string) (string, error) {

	lcId := args

	// if err != nil {
	// 	return fmt.Errorf("No Amount")
	// }

	LCAsBytes, _ := APIstub.GetStub().GetState(lcId)

	return string(LCAsBytes), nil
}

func (s *TfbcChaincode) GetLCHistory(APIstub contractapi.TransactionContextInterface, args string) (string, error) {

	lcId := args

	resultsIterator, err := APIstub.GetStub().GetHistoryForKey(lcId)
	if err != nil {
		return "", fmt.Errorf("Error retrieving LC history.")
	}
	defer resultsIterator.Close()

	// buffer is a JSON array containing historic values for the marble
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		response, err := resultsIterator.Next()
		if err != nil {
			return "", fmt.Errorf("Error retrieving LC history.")
		}
		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"TxId\":")
		buffer.WriteString("\"")
		buffer.WriteString(response.TxId)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Value\":")
		// if it was a delete operation on given key, then we need to set the
		//corresponding value null. Else, we will write the response.Value
		//as-is (as the Value itself a JSON marble)
		if response.IsDelete {
			buffer.WriteString("null")
		} else {
			buffer.WriteString(string(response.Value))
		}

		buffer.WriteString(", \"Timestamp\":")
		buffer.WriteString("\"")
		buffer.WriteString(time.Unix(response.Timestamp.Seconds, int64(response.Timestamp.Nanos)).String())
		buffer.WriteString("\"")

		buffer.WriteString(", \"IsDelete\":")
		buffer.WriteString("\"")
		buffer.WriteString(strconv.FormatBool(response.IsDelete))
		buffer.WriteString("\"")

		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	fmt.Printf("- getLCHistory returning:\n%s\n", buffer.String())

	return buffer.String(), nil
}
