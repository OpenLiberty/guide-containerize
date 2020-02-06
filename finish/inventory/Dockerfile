# tag::from[]
FROM open-liberty
# end::from[]

ARG VERSION=1.0
ARG REVISION=SNAPSHOT

# tag::label[]
LABEL io.openliberty.guide.image.authors="My Name" \
      io.openliberty.guide.image.vendor="Open Liberty" \
      io.openliberty.guide.image.name="inventory" \
      io.openliberty.guide.image.version="$VERSION-$REVISION" \
      io.openliberty.guide.image.source="https://github.com/OpenLiberty/guide-containerize"
# end::label[]

# tag::copy-config[]
# tag::config-userID[]
COPY --chown=1001:0 \
# end::config-userID[]
    # tag::inventory-config[]
    src/main/liberty/config \
    # end::inventory-config[]
    # tag::config[]
    /config/
    # end::config[]
# end::copy-config[]

# tag::copy-war[]
# tag::war-userID[]
COPY --chown=1001:0 \
# end::war-userID[]
    # tag::inventory-war[]
    target/inventory.war \
    # end::inventory-war[]
    # tag::config-apps[]
    /config/apps
    # end::config-apps[]
# end::copy-war[]

# tag::configure-sh[]
RUN configure.sh
# end::configure-sh[]