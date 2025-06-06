#!/bin/bash
set -euxo pipefail
./mvnw -version

cd ../start

./mvnw -ntp -Dhttp.keepAlive=false \
    -Dmaven.wagon.http.pool=false \
    -Dmaven.wagon.httpconnectionManager.ttlSeconds=120 \
    -q clean package
./mvnw -ntp -Dhttp.keepAlive=false \
    -Dmaven.wagon.http.pool=false \
    -Dmaven.wagon.httpconnectionManager.ttlSeconds=120 \
    -q -pl system liberty:create liberty:install-feature liberty:deploy
./mvnw -ntp -Dhttp.keepAlive=false \
    -Dmaven.wagon.http.pool=false \
    -Dmaven.wagon.httpconnectionManager.ttlSeconds=120 \
    -q -pl inventory liberty:create liberty:install-feature liberty:deploy

./mvnw -ntp -pl system liberty:start
./mvnw -ntp -pl inventory liberty:start

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

./mvnw -ntp -pl system liberty:stop
./mvnw -ntp -pl inventory liberty:stop

