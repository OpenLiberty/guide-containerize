# tag::from[]
FROM open-liberty
# end::from[]

# tag::copy-config[]
# tag::config-userID[]
COPY --chown=1001:0 \
# end::config-userID[]
    # tag::inventory-config[]
    src/main/liberty/config \
    # end::inventory-config[]
    # tag::config[]
    /config/
    # tag::config[]
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

# tag::configure[]
RUN configure.sh
# end::configure[]