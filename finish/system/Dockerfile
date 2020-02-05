FROM open-liberty

ARG VERSION=1.0
ARG REVISION=SNAPSHOT

LABEL org.opencontainers.image.authors="My Name" \
      org.opencontainers.image.vendor="Open Liberty" \
      org.opencontainers.image.url="https://hub.docker.com/" \
      org.opencontainers.image.source="https://github.com/OpenLiberty/guide-containerize" \
      org.opencontainers.image.version="$VERSION" \
      org.opencontainers.image.revision="$REVISION" \
      vendor="Open Liberty" \
      name="system" \
      version="$VERSION:$REVISION" \
      summary="The system microservice from the Containerizing microservices guide" \
      description="This image contains the system microservice running with Open Liberty runtime." \
      io.openliberty.guide.name="guide-containerize"
COPY --chown=1001:0 src/main/liberty/config /config/
# tag::copy-war[]
COPY --chown=1001:0 target/system.war /config/apps
# end::copy-war[]

RUN configure.sh