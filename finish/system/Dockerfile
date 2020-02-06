FROM open-liberty

ARG VERSION=1.0
ARG REVISION=SNAPSHOT

LABEL io.openliberty.guide.image.authors="My Name" \
      io.openliberty.guide.image.vendor="Open Liberty" \
      io.openliberty.guide.image.name="system" \
      io.openliberty.guide.image.version="$VERSION-$REVISION" \
      io.openliberty.guide.image.source="https://github.com/OpenLiberty/guide-containerize"
COPY --chown=1001:0 src/main/liberty/config /config/
# tag::copy-war[]
COPY --chown=1001:0 target/system.war /config/apps
# end::copy-war[]

RUN configure.sh