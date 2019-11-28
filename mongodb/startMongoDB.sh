#!/bin/bash
MONGODB_DOCK_NAME=mongo-test

echo "= Cleaning up MongoDB container"
docker rm -f $MONGODB_DOCK_NAME

echo "= Bringing up the MongoDB"
DOCKER_ID=`docker run --name $MONGODB_DOCK_NAME -p 27017:27017 -d mongo --auth`

echo "= Setting up root user"
docker exec $DOCKER_ID mongo admin --eval "db.createUser({ user: 'admin', pwd: 'pass', roles: [ { role: 'root', db: 'admin'} ] });"
echo "= Setting up Dummy DB"
docker exec $DOCKER_ID apt update
docker exec $DOCKER_ID apt install -y wget
docker exec $DOCKER_ID wget https://raw.githubusercontent.com/mongodb/docs-assets/primer-dataset/primer-dataset.json
docker exec $DOCKER_ID mongo admin -u admin -p 'pass' --eval "db=db.getSiblingDB('test'); db.createCollection('restaurants', { size: 2147483648 } );"
docker exec $DOCKER_ID mongoimport -u admin -p 'pass' --authenticationDatabase admin --db test --collection restaurants --file primer-dataset.json

echo "= Running the MongoDBExpress"
docker run --rm --link $MONGODB_DOCK_NAME:mongo -p 8081:8081 -e ME_CONFIG_MONGODB_ADMINUSERNAME='admin' -e ME_CONFIG_MONGODB_ADMINPASSWORD='pass' mongo-express