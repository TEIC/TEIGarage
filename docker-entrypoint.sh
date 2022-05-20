#!/bin/sh

# download TEI resources to /tmp on host if not there already & unzip TEI resources and move them to correct folder - keep as comments for further reference
#FILE_STY=/usr/share/xml/tei/stylesheet/profiles
#if [ -d "$FILE_STY" ]; then
#    echo "$FILE_STY exists."
#else 
#    echo "$FILE_STY will be downloaded."
#    DOWNLOAD_URL_STY=$(curl -s https://api.github.com/repos/TEIC/Stylesheets/releases/latest \
#        | grep browser_download_url \
#        | cut -d '"' -f 4)
#    curl -s -L -o /tmp/stylesheet.zip "$DOWNLOAD_URL_STY"
#    unzip /tmp/stylesheet.zip -d /tmp/stylesheet
#    rm /tmp/stylesheet.zip
#    mkdir /usr/share/xml/tei/stylesheet
#    cp -r /tmp/stylesheet/xml/tei/stylesheet/* /usr/share/xml/tei/stylesheet    
#    rm -r /tmp/stylesheet
#fi
#
#FILE_ODD=/usr/share/xml/tei/odd/p5subset.xml
#if [ -f "$FILE_ODD" ]; then
#    echo "$FILE_ODD exists."
#else 
#    echo "$FILE_ODD will be downloaded."
#    DOWNLOAD_URL_ODD=$(curl -s https://api.github.com/repos/TEIC/TEI/releases/latest \
#        | grep browser_download_url \
#        | cut -d '"' -f 4)
#    curl -s -L -o /tmp/odd.zip "$DOWNLOAD_URL_ODD"
#    unzip /tmp/odd.zip -d /tmp/odd
#    rm /tmp/odd.zip
#    mkdir /usr/share/xml/tei/odd
#    cp -r /tmp/odd/xml/tei/odd/* /usr/share/xml/tei/odd
#    rm -r /tmp/odd
#fi

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
