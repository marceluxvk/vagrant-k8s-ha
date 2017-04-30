#!/bin/bash
cd bartender

export GOPATH=`pwd`
echo "Compiling...."
go build -o dist/main src/main.go

echo "Build docker image"

docker build . -t base.local:5000/example2-bartender:1.0.0

echo "Pushing the component to the global docker repository"
docker push base.local:5000/example2-bartender:1.0.0

cd ..
cd customer

echo "Compiling...."
go build -o dist/main src/main.go

echo "Build docker image"

docker build . -t base.local:5000/example2-customer:1.0.0

echo "Pushing the component to the global docker repository"
docker push base.local:5000/example2-customer:1.0.0

cd ..