# Steps to run samples

## Pre requirements

- Run below command to Get all the docker images
```bash
curl -sSL https://bit.ly/2ysbOFE | bash -s -- 2.2.3 1.4.9
```

## Steps to run the Tbfc sample blockchain network

- Follow below commands after cloning the repository.

```bash
cd <cloned_repository_name>

cd ./hlf-network

./network.sh up createChannel -ca -c mychannel -s couchdb -i 2.2.3

./network.sh deployCC -ccn tfbc -ccp ../chaincode/tfbc/go -ccl go

cd ../tbfc-api

npm i

node registerBuyerUser.js

node registerSellerUser.js

npm start

```

Now open http://localhost:3000/api-docs to access swagger ui.



