FROM open-liberty
COPY --chown=1001:0 src/main/liberty/config /config/
# tag::copy-war[]
COPY --chown=1001:0 target/system.war /config/apps
# end::copy-war[]
RUN configure.sh