#########################################
# multi stage Dockerfile for creating a Docker image
# 1. set up the build environment and build the war files
# 2. run an application server with the web applications from 1
#########################################
FROM maven:3-jdk-8 as builder
LABEL maintainer="Peter Stadler for the TEI Council"

ENV OXGARAGE_BUILD_HOME="/opt/oxgarage-build"

WORKDIR ${OXGARAGE_BUILD_HOME}

COPY . .

# build the application packages
# need to rename saxon jar to avoid class loader issues with old versions
# see https://github.com/peterstadler/oxgarage-docker/issues/2#issuecomment-358663386
RUN mvn install


#########################################
# Now configuring the application server
# and adding our freshly built war packages
#########################################
FROM tomcat:7

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

# installs lilypond into /usr/local/lilypond and /usr/local/bin as shortcut
ADD https://lilypond.org/download/binaries/linux-64/lilypond-2.20.0-1.linux-64.sh /tmp/lilypond.sh
RUN chmod a+x /tmp/lilypond.sh \
    && /tmp/lilypond.sh --batch

# clone and run
RUN git clone -b master https://github.com/rism-ch/verovio /tmp/verovio \
    && cd /tmp/verovio/tools \
    && cmake ../cmake \
    && make -j 8 \
    && make install \
    && cp /tmp/verovio/fonts/VerovioText-1.0.ttf /usr/local/share/fonts/ \
    && fc-cache

# copy some settings and entrypoint script
COPY ege-webservice/src/main/webapp/WEB-INF/lib/oxgarage.properties /etc/
COPY log4j.xml /var/cache/oxgarage/log4j.xml
COPY docker-entrypoint.sh /my-docker-entrypoint.sh

# copy build artifacts 
COPY --from=builder /opt/oxgarage-build/ege-webclient/target/ege-webclient.war /tmp/ege-webclient.war
COPY --from=builder /opt/oxgarage-build/ege-webservice/target/ege-webservice.war /tmp/ege-webservice.war
       
RUN rm -Rf ${CATALINA_WEBAPPS}/ROOT \
    && unzip -q /tmp/ege-webclient.war -d ${CATALINA_WEBAPPS}/ROOT/ \
    && unzip -q /tmp/teigarage.war -d ${CATALINA_WEBAPPS}/teigarage/ \
    && rm /tmp/ege-webclient.war \
    && rm /tmp/ege-webservice.war \
    && chmod 755 /my-docker-entrypoint.sh

VOLUME ["/usr/share/xml/tei/stylesheet", "/usr/share/xml/tei/odd"]

EXPOSE 8080 8081

ENTRYPOINT ["/my-docker-entrypoint.sh"]
CMD ["catalina.sh", "run"]
