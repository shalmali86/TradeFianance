#!/bin/bash

function createbuyer() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/buyer.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/buyer.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-buyer --tls.certfiles ${PWD}/organizations/fabric-ca/buyer/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-buyer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-buyer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-buyer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-buyer.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/buyer.example.com/msp/config.yaml

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-buyer --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/buyer/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-buyer --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/buyer/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-buyer --id.name buyeradmin --id.secret buyeradminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/buyer/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-buyer -M ${PWD}/organizations/peerOrganizations/buyer.example.com/peers/peer0.buyer.example.com/msp --csr.hosts peer0.buyer.example.com --tls.certfiles ${PWD}/organizations/fabric-ca/buyer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/buyer.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/buyer.example.com/peers/peer0.buyer.example.com/msp/config.yaml

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-buyer -M ${PWD}/organizations/peerOrganizations/buyer.example.com/peers/peer0.buyer.example.com/tls --enrollment.profile tls --csr.hosts peer0.buyer.example.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/buyer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/buyer.example.com/peers/peer0.buyer.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/buyer.example.com/peers/peer0.buyer.example.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/buyer.example.com/peers/peer0.buyer.example.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/buyer.example.com/peers/peer0.buyer.example.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/buyer.example.com/peers/peer0.buyer.example.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/buyer.example.com/peers/peer0.buyer.example.com/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/buyer.example.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/buyer.example.com/peers/peer0.buyer.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/buyer.example.com/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/buyer.example.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/buyer.example.com/peers/peer0.buyer.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/buyer.example.com/tlsca/tlsca.buyer.example.com-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/buyer.example.com/ca
  cp ${PWD}/organizations/peerOrganizations/buyer.example.com/peers/peer0.buyer.example.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/buyer.example.com/ca/ca.buyer.example.com-cert.pem

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-buyer -M ${PWD}/organizations/peerOrganizations/buyer.example.com/users/User1@buyer.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/buyer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/buyer.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/buyer.example.com/users/User1@buyer.example.com/msp/config.yaml

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://buyeradmin:buyeradminpw@localhost:7054 --caname ca-buyer -M ${PWD}/organizations/peerOrganizations/buyer.example.com/users/Admin@buyer.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/buyer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/buyer.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/buyer.example.com/users/Admin@buyer.example.com/msp/config.yaml
}

function createseller() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/seller.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/seller.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-seller --tls.certfiles ${PWD}/organizations/fabric-ca/seller/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-seller.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-seller.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-seller.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-seller.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/seller.example.com/msp/config.yaml

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-seller --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/seller/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-seller --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/seller/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-seller --id.name selleradmin --id.secret selleradminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/seller/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-seller -M ${PWD}/organizations/peerOrganizations/seller.example.com/peers/peer0.seller.example.com/msp --csr.hosts peer0.seller.example.com --tls.certfiles ${PWD}/organizations/fabric-ca/seller/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/seller.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/seller.example.com/peers/peer0.seller.example.com/msp/config.yaml

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-seller -M ${PWD}/organizations/peerOrganizations/seller.example.com/peers/peer0.seller.example.com/tls --enrollment.profile tls --csr.hosts peer0.seller.example.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/seller/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/seller.example.com/peers/peer0.seller.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/seller.example.com/peers/peer0.seller.example.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/seller.example.com/peers/peer0.seller.example.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/seller.example.com/peers/peer0.seller.example.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/seller.example.com/peers/peer0.seller.example.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/seller.example.com/peers/peer0.seller.example.com/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/seller.example.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/seller.example.com/peers/peer0.seller.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/seller.example.com/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/seller.example.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/seller.example.com/peers/peer0.seller.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/seller.example.com/tlsca/tlsca.seller.example.com-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/seller.example.com/ca
  cp ${PWD}/organizations/peerOrganizations/seller.example.com/peers/peer0.seller.example.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/seller.example.com/ca/ca.seller.example.com-cert.pem

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-seller -M ${PWD}/organizations/peerOrganizations/seller.example.com/users/User1@seller.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/seller/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/seller.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/seller.example.com/users/User1@seller.example.com/msp/config.yaml

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://selleradmin:selleradminpw@localhost:8054 --caname ca-seller -M ${PWD}/organizations/peerOrganizations/seller.example.com/users/Admin@seller.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/seller/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/seller.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/seller.example.com/users/Admin@seller.example.com/msp/config.yaml
}

function createOrderer() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/ordererOrganizations/example.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/example.com

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml

  infoln "Registering orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/config.yaml

  infoln "Generating the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls --enrollment.profile tls --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/keystore/* ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key

  mkdir -p ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  mkdir -p ${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  infoln "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp/config.yaml
}
