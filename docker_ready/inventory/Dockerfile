# Using Slim Java Liberty base image
FROM icr.io/appcafe/open-liberty:kernel-slim-java11-openj9-ubi

# Execute mvn package in docker build stage --> Habra que
# meterlo en una imagen que tenga mvn, porque esta creo que no lo tiene
# Revisarlo en la documentación
# RUN mvn package

# Define env vars only available in the build phase
ARG VERSION=1.0
ARG REVISION=SNAPSHOT

# Add generic metadata to base image
LABEL \
  org.opencontainers.image.authors="Your Name" \
  org.opencontainers.image.vendor="Open Liberty" \
  org.opencontainers.image.url="local" \
  org.opencontainers.image.source="https://github.com/OpenLiberty/guide-containerize" \
  org.opencontainers.image.version="$VERSION" \
  org.opencontainers.image.revision="$REVISION" \
  vendor="Open Liberty" \
  name="inventory" \
  version="$VERSION-$REVISION" \
  summary="The inventory microservice from the Containerizing microservices guide" \
  description="This image contains the inventory microservice running with the Open Liberty runtime."

# Copy local files to image
## --chown:1001:0 => User:1001 / Group:0
COPY --chown=1001:0 src/main/liberty/config /config

# Execute base image features.sh binary
RUN features.sh

# Copy local files to image
## --chown:1001:0 => User:1001 / Group:0ç
## To have target/guide-containerxxx.war file locally a mvn package is needed
COPY --chown=1001:0 target/guide-containerize-inventory.war /config/apps

# Execute base image features.sh binary
RUN configure.sh