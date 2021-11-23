#!/bin/bash
set -euxo pipefail

##############################################################################
##
##  Travis CI test script
##
##############################################################################

cd ../finish

mvn -Dhttp.keepAlive=false \
    -Dmaven.wagon.http.pool=false \
    -Dmaven.wagon.httpconnectionManager.ttlSeconds=120 \
    -q clean package
    
docker pull openliberty/open-liberty:kernel-java8-openj9-ubi

docker build -t system system/.
docker build -t inventory inventory/.

docker images -f "label=org.opencontainers.image.authors=Your Name" | grep system
docker images -f "label=org.opencontainers.image.authors=Your Name" | grep inventory

docker run -d --name system -p 9080:9080 system
docker run -d --name inventory -p 9081:9081 inventory

sleep 120

systemStatus="$(curl --write-out "%{http_code}\n" --silent --output /dev/null "http://localhost:9080/system/properties/")"
inventoryStatus="$(curl --write-out "%{http_code}\n" --silent --output /dev/null "http://localhost:9081/inventory/systems/")"

if [ "$systemStatus" == "200" ] && [ "$inventoryStatus" == "200" ]
then
  echo ENDPOINT OK
else
  echo inventory status:
  echo "$inventoryStatus"
  echo system status:
  echo "$systemStatus"
  echo ENDPOINT
  exit 1
fi

docker stop inventory
docker rm inventory
docker run -d --name inventory -e default.http.port=9091 -p 9091:9091 inventory

sleep 30

inventoryStatus="$(curl --write-out "%{http_code}\n" --silent --output /dev/null "http://localhost:9091/inventory/systems/")"

if [ "$inventoryStatus" == "200" ]
then
  echo ENDPOINT OK
else
  echo inventory status:
  echo "$inventoryStatus"
  echo ENDPOINT
  exit 1
fi

docker stop inventory system
docker rm inventory system
