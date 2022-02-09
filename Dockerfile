#########################################
# Dockerfile for setting up the TEIGarage.
# This installs dependencies to the system, 
# then downloads the latest artifacts 
# of both the ege-webclient and the TEIGarage (backend),
# and installs it in a Tomcat application server
#########################################
FROM tomcat:9-jdk11-openjdk

LABEL org.opencontainers.image.source=https://github.com/teic/teigarage

ARG VERSION_STYLESHEET=latest
ARG VERSION_ODD=latest
ARG WEBSERVICE_ARTIFACT=https://nightly.link/TEIC/TEIGarage/workflows/maven/dev/artifact.zip
ARG WEBCLIENT_ARTIFACT=https://nightly.link/TEIC/ege-webclient/workflows/maven/main/artifact.zip

ENV CATALINA_WEBAPPS ${CATALINA_HOME}/webapps
ENV OFFICE_HOME /usr/lib/libreoffice
ENV TEI_SOURCES_HOME /usr/share/xml/tei

USER root:root

RUN apt-get update \
    && apt-get install --no-install-recommends -y libreoffice \
    fonts-dejavu \
    fonts-arphic-ukai \
    fonts-arphic-uming \
    fonts-baekmuk \
    fonts-junicode \
    fonts-linuxlibertine \
    fonts-ipafont-gothic \
    fonts-ipafont-mincho \
    cmake \
    build-essential \
    libgcc-10-dev \
    librsvg2-bin \
    curl \
    && ln -s ${OFFICE_HOME} /usr/lib/openoffice \
    && rm -rf /var/lib/apt/lists/*

# entrypoint script
COPY docker-entrypoint.sh /my-docker-entrypoint.sh

# log4j.xml configuration
COPY log4j.xml /var/cache/oxgarage/log4j.xml

# we could download the artifacts directly from GitHub but then
# we would need to pass in secrets since the GitHub API does not allow
# anonyous access. The following code is only for reference:  
#RUN --mount=type=secret,id=GITHUB_USER --mount=type=secret,id=GITHUB_TOKEN \
#    curl -u $(cat /run/secrets/GITHUB_USER):$(cat /run/secrets/GITHUB_TOKEN) -Ls $(curl -u $(cat /run/secrets/GITHUB_USER):$(cat /run/secrets/GITHUB_TOKEN) -Ls -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/TEIC/TEIGarage/actions/artifacts | jq -r ".artifacts[0].archive_download_url") -o /tmp/teigarage.zip \  
#    && curl -u $(cat /run/secrets/GITHUB_USER):$(cat /run/secrets/GITHUB_TOKEN) -Ls $(curl -u $(cat /run/secrets/GITHUB_USER):$(cat /run/secrets/GITHUB_TOKEN) -Ls -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/TEIC/ege-webclient/actions/artifacts | jq -r ".artifacts[0].archive_download_url") -o /tmp/webservice.zip \
#    && unzip /tmp/teigarage.zip -d /tmp/ \
#    && unzip /tmp/webservice.zip -d /tmp/  

# download artifacts to /tmp and deploy them at ${CATALINA_WEBAPPS}
# these war-files are zipped so we need to unzip them twice
RUN rm -Rf ${CATALINA_WEBAPPS}/ROOT \
    && curl -Ls ${WEBSERVICE_ARTIFACT} -o /tmp/teigarage.zip \
    && curl -Ls ${WEBCLIENT_ARTIFACT} -o /tmp/webclient.zip \
    && unzip -q /tmp/webclient.zip -d /tmp/ \
    && unzip -q /tmp/teigarage.zip -d /tmp/ \
    && unzip -q /tmp/ege-webclient.war -d ${CATALINA_WEBAPPS}/ROOT/ \
    && unzip -q /tmp/teigarage.war -d ${CATALINA_WEBAPPS}/ege-webservice/ \
    && cp ${CATALINA_WEBAPPS}/ege-webservice/WEB-INF/lib/oxgarage.properties /etc/ \
    && rm /tmp/*.war \
    && rm /tmp/*.zip \
    && chmod 755 /my-docker-entrypoint.sh

#check if the version of stylesheet version is supplied, if not find out latest version
RUN if [ "$VERSION_STYLESHEET" = "latest" ] ; then \
    VERSION_STYLESHEET=$(curl "https://api.github.com/repos/TEIC/Stylesheets/releases/latest" | grep -Po '"tag_name": "v\K.*?(?=")'); \    
    fi \
    && echo "Stylesheet version set to ${VERSION_STYLESHEET}" \
    # download the required tei odd and stylesheet sources in the image and move them to the respective folders (${TEI_SOURCES_HOME})
    && curl -s -L -o /tmp/stylesheet.zip https://github.com/TEIC/Stylesheets/releases/download/v${VERSION_STYLESHEET}/tei-xsl-${VERSION_STYLESHEET}.zip \
    && unzip /tmp/stylesheet.zip -d /tmp/stylesheet \
    && rm /tmp/stylesheet.zip \
    && mkdir -p  ${TEI_SOURCES_HOME}/stylesheet \
    && cp -r /tmp/stylesheet/xml/tei/stylesheet/*  ${TEI_SOURCES_HOME}/stylesheet \
    && rm -r /tmp/stylesheet

RUN if [ "$VERSION_ODD" = "latest" ] ; then \
    VERSION_ODD=$(curl "https://api.github.com/repos/TEIC/TEI/releases/latest" | grep -Po '"tag_name": "P5_Release_\K.*?(?=")'); \   
    fi \
    && echo "ODD version set to ${VERSION_ODD}" \
    # download the required tei odd and stylesheet sources in the image and move them to the respective folders ( ${TEI_SOURCES_HOME})
    && curl -s -L -o /tmp/odd.zip https://github.com/TEIC/TEI/releases/download/P5_Release_${VERSION_ODD}/tei-${VERSION_ODD}.zip \
    && unzip /tmp/odd.zip -d /tmp/odd \
    && rm /tmp/odd.zip \
    && mkdir -p  ${TEI_SOURCES_HOME}/odd \
    && cp -r /tmp/odd/xml/tei/odd/*  ${TEI_SOURCES_HOME}/odd \
    && rm -r /tmp/odd

VOLUME ["/usr/share/xml/tei/stylesheet", "/usr/share/xml/tei/odd"]

EXPOSE 8080 8081

ENTRYPOINT ["/my-docker-entrypoint.sh"]
CMD ["catalina.sh", "run"]
