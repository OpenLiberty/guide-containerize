FROM open-liberty

ADD --chown=1001:0 target/liberty/wlp/usr/servers/defaultServer/bootstrap.properties \
                    /config
ADD --chown=1001:0 target/liberty/wlp/usr/servers/defaultServer/server.env /config
ADD --chown=1001:0 src/main/liberty/config/server.xml /config
ADD --chown=1001:0 target/*.tar.gz /opt/ol
