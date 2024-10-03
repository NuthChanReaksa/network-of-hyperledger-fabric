#!/bin/bash

../bin/configtxgen -profile OrdererGenesis -outputBlock ./channel-artifacts/genesis.block -channelID channelorderergenesis
../bin/configtxgen -profile ChannelDemo -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID channeldemo

../bin/configtxgen -profile ChannelDemo -outputAnchorPeersUpdate ./channel-artifacts/Burakcan1Anchor.tx -channelID channeldemo -asOrg Burakcan1MSP
../bin/configtxgen -profile ChannelDemo -outputAnchorPeersUpdate ./channel-artifacts/Burakcan2Anchor.tx -channelID channeldemo -asOrg Burakcan2MSP


 docker compose -f docker-compose-cli.yaml  down -v
docker compose -f docker-compose-cli.yaml  up -d

echo COMPOSE_PROJECT_NAME=net > .env


# for org1 
docker exec -e "CORE_PEER_LOCALMSPID=Burakcan1MSP" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/fabric-samples/burakcan-network/crypto-config/peerOrganizations/be1.burakcan-network.com/peers/peer0.be1.burakcan-network.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/fabric-samples/burakcan-network/crypto-config/peerOrganizations/be1.burakcan-network.com/users/Admin@be1.burakcan-network.com/msp" -e "CORE_PEER_ADDRESS=peer0.be1.burakcan-network.com:7051" -it cli bash

# for org2 
docker exec -e "CORE_PEER_LOCALMSPID=Burakcan2MSP" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/fabric-samples/burakcan-network/crypto-config/peerOrganizations/be2.burakcan-network.com/peers/peer0.be2.burakcan-network.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/fabric-samples/burakcan-network/crypto-config/peerOrganizations/be2.burakcan-network.com/users/Admin@be2.burakcan-network.com/msp" -e "CORE_PEER_ADDRESS=peer0.be2.burakcan-network.com:7051" -it cli bash


export ORDERER_CA=/opt/gopath/fabric-samples/burakcan-network/crypto-config/ordererOrganizations/burakcan-network.com/orderers/orderer.burakcan-network.com/msp/tlscacerts/tlsca.burakcan-network.com-cert.pem

## create channel-demo 
peer channel create -o orderer.burakcan-network.com:7050 \
    -c channeldemo \
    -f /opt/gopath/fabric-samples/burakcan-network/channel-artifacts/channel.tx \
    --tls --cafile $ORDERER_CA

peer channel join -b channeldemo.block --tls --cafile $ORDERER_CA

# set anchor peer org1 
peer channel update -o orderer.burakcan-network.com:7050 -c channeldemo -f /opt/gopath/fabric-samples/burakcan-network/channel-artifacts/Burakcan1Anchor.tx --tls --cafile $ORDERER_CA

# org2 
peer channel update -o orderer.burakcan-network.com:7050 -c channeldemo -f /opt/gopath/fabric-samples/burakcan-network/channel-artifacts/Burakcan2Anchor.tx --tls --cafile $ORDERER_CA

# create directory
mkdir /opt/gopath/src/chain/be_chaincode
mkdir /opt/gopath/src/chain/be_chaincode/go
vi /opt/gopath/src/chain/be_chaincode/go/be.go