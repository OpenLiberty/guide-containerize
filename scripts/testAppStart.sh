#!/bin/bash
set -euxo pipefail

cd ../start

mvn -q clean package
mvn -q -pl system liberty:create liberty:install-feature liberty:deploy
mvn -q -pl inventory liberty:create liberty:install-feature liberty:deploy

mvn -pl system liberty:start
mvn -pl inventory liberty:start

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

mvn -pl system liberty:stop
mvn -pl inventory liberty:stop

