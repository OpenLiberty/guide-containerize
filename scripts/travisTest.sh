#!/bin/bash
set -euxo pipefail

##############################################################################
##
##  Travis CI test script
##
##############################################################################

cd ../finish

mvn -q clean package

docker pull open-liberty

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

docker stop inventory system
docker rm inventory system
