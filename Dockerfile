#########################################
# Dockerfile for setting up the TEIGarage.
# This installs dependencies to the system, 
# then downloads the latest artifacts 
# of both the ege-webclient and the TEIGarage (backend),
# and installs it in a Tomcat application server
#########################################
FROM tomcat:7

LABEL org.opencontainers.image.source=https://github.com/teic/teigarage

ARG URL_STYLESHEET_SOURCES=https://github.com/TEIC/Stylesheets/releases/download/v7.52.0/tei-xsl-7.52.0.zip
ARG URL_ODD_SOURCES=https://github.com/TEIC/TEI/releases/download/P5_Release_4.3.0/tei-4.3.0.zip

RUN echo "Stylesheet url set to ${URL_STYLESHEET_SOURCES}"
RUN echo "Odd url set to ${URL_ODD_SOURCES}"

ENV CATALINA_WEBAPPS ${CATALINA_HOME}/webapps
ENV OFFICE_HOME /usr/lib/libreoffice

USER root:root

RUN apt-get update \
    && apt-get install -y libreoffice \
    ttf-dejavu \
    fonts-arphic-ukai \
    fonts-arphic-uming \
    fonts-baekmuk \
    fonts-junicode \
    fonts-linuxlibertine \
    fonts-ipafont-gothic \
    fonts-ipafont-mincho \
    cmake \
    build-essential \
    libgcc-8-dev \
    librsvg2-bin \
    && ln -s ${OFFICE_HOME} /usr/lib/openoffice \
    && rm -rf /var/lib/apt/lists/*

# entrypoint script
COPY docker-entrypoint.sh /my-docker-entrypoint.sh

# log4j.xml configuration
COPY log4j.xml /var/cache/oxgarage/log4j.xml

# download artifacts to /tmp
# these war-files are zipped so we need to unzip them twice at the next stage 
ADD https://nightly.link/TEIC/TEIGarage/workflows/maven/main/artifact.zip /tmp/teigarage.zip
ADD https://nightly.link/TEIC/ege-webclient/workflows/maven/main/artifact.zip /tmp/webservice.zip

# we could download the artifacts directly from GitHub but then
# we would need to pass in secrets since the GitHub API does not allow
# anonyous access. The following code is only for reference:  
#RUN --mount=type=secret,id=GITHUB_USER --mount=type=secret,id=GITHUB_TOKEN \
#    curl -u $(cat /run/secrets/GITHUB_USER):$(cat /run/secrets/GITHUB_TOKEN) -Ls $(curl -u $(cat /run/secrets/GITHUB_USER):$(cat /run/secrets/GITHUB_TOKEN) -Ls -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/TEIC/TEIGarage/actions/artifacts | jq -r ".artifacts[0].archive_download_url") -o /tmp/teigarage.zip \  
#    && curl -u $(cat /run/secrets/GITHUB_USER):$(cat /run/secrets/GITHUB_TOKEN) -Ls $(curl -u $(cat /run/secrets/GITHUB_USER):$(cat /run/secrets/GITHUB_TOKEN) -Ls -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/TEIC/ege-webclient/actions/artifacts | jq -r ".artifacts[0].archive_download_url") -o /tmp/webservice.zip \
#    && unzip /tmp/teigarage.zip -d /tmp/ \
#    && unzip /tmp/webservice.zip -d /tmp/  

RUN rm -Rf ${CATALINA_WEBAPPS}/ROOT \
    && unzip -q /tmp/webservice.zip -d /tmp/ \
    && unzip -q /tmp/teigarage.zip -d /tmp/ \
    && unzip -q /tmp/ege-webclient.war -d ${CATALINA_WEBAPPS}/ROOT/ \
    && unzip -q /tmp/teigarage.war -d ${CATALINA_WEBAPPS}/ege-webservice/ \
    && cp ${CATALINA_WEBAPPS}/ege-webservice/WEB-INF/lib/oxgarage.properties /etc/ \
    && rm /tmp/*.war \
    && rm /tmp/*.zip \
    && chmod 755 /my-docker-entrypoint.sh



# download the required tei odd and stylesheet sources in the image and move them to the respective folders (/usr/share/xml/tei/)
ADD ${URL_STYLESHEET_SOURCES} /tmp/stylesheet.zip
RUN unzip /tmp/stylesheet.zip -d /tmp/stylesheet \
    && rm /tmp/stylesheet.zip \
    && mkdir -p /usr/share/xml/tei/stylesheet \
    && cp -r /tmp/stylesheet/xml/tei/stylesheet/* /usr/share/xml/tei/stylesheet \
    && rm -r /tmp/stylesheet

ADD ${URL_ODD_SOURCES} /tmp/odd.zip 
RUN unzip /tmp/odd.zip -d /tmp/odd \
    && rm /tmp/odd.zip \
    && mkdir -p /usr/share/xml/tei/odd \
    && cp -r /tmp/odd/xml/tei/odd/* /usr/share/xml/tei/odd \
    && rm -r /tmp/odd

VOLUME ["/usr/share/xml/tei/stylesheet", "/usr/share/xml/tei/odd"]

EXPOSE 8080 8081

ENTRYPOINT ["/my-docker-entrypoint.sh"]
CMD ["catalina.sh", "run"]
