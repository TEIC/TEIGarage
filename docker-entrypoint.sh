#!/bin/sh

# setting the webservice URL for the client
sed -i -e "s@http:\/\/localhost:8080\/ege-webservice\/@$WEBSERVICE_URL@" ${CATALINA_WEBAPPS}/ROOT/WEB-INF/web.xml  

# adding a HTTPS connector.
# Define the connector on port 8081 to handle
# originating HTTPS requests. Here we
# set scheme to https and secure to true. Tomcat
# will still serve this as plain HTTP because
# SSLEnabled is set to false.
# See https://creechy.wordpress.com/2011/08/22/ssl-termination-load-balancers-java/
CONNECTOR='<Connector port="8081" protocol="HTTP/1.1" maxThreads="150" clientAuth="false" SSLEnabled="false" scheme="https" secure="true" proxyPort="443" />';
sed -i -e "s@<Service name=\"Catalina\">@<Service name=\"Catalina\">$CONNECTOR@" ${CATALINA_HOME}/conf/server.xml

# run the command given in the Dockerfile at CMD 
exec "$@"