#!/bin/bash
set -euxo pipefail

##############################################################################
##
##  Travis CI test script
##
##############################################################################

mvn -q clean install

cd ../finish

mvn -q clean install -DskipTests

docker pull open-liberty

docker build -t system system/.
docker build -t inventory inventory/.

docker run -d --name system -p 9080:9080 system
docker run -d --name inventory -p 9081:9081 inventory

sleep 60

systemStatus="$(curl --write-out "%{http_code}\n" --silent --output /dev/null "http://localhost:9080/system/properties/")"
inventoryStatus="$(curl --write-out "%{http_code}\n" --silent --output /dev/null "http://localhost:9081/inventory/systems/")"
if [ "$status" == "200" ]
then
  echo ENDPOINT OK
else
  echo "$status"
  echo ENDPOINT
  exit 1
fi

docker stop inventory system
docker rm inventory system
