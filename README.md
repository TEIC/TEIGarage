# TEIGarage

[![Build Status](https://github.com/TEIC/TEIGarage/actions/workflows/maven.yml/badge.svg)](https://github.com/TEIC/TEIGarage/actions/workflows/maven.yml)
[![Docker Automated build](https://github.com/TEIC/TEIGarage/actions/workflows/docker.yml/badge.svg)](https://github.com/TEIC/TEIGarage/actions/workflows/docker.yml)
[![GitHub license](https://img.shields.io/github/license/teic/TEIGarage.svg)](https://github.com/TEIC/TEIGarage/blob/main/LICENSE)
[![GitHub release](https://img.shields.io/github/v/release/TEIC/TEIGarage.svg)](https://github.com/TEIC/TEIGarage/releases)

<!-- TABLE OF CONTENTS -->
## Table of Contents

* [About the Project](#about)
* [Installation](#installation)
    * [With Docker](#installing-with-docker)
    * [Without Docker](#installing-without-docker)
* [Building with Maven](#building-with-maven)


# About

TEIGarage is a webservice and RESTful service to transform, convert and validate various formats, focussing on the [TEI](https://tei-c.org/) format.
TEIGarage is based on the proven [OxGarage](https://github.com/TEIC/oxgarage). 

Further information on the code structure of MEIGarage and TEIGarage can be found [here](https://github.com/Edirom/MEIGarage/blob/main/doc/code-structure.md).

# Installation

## Installing with Docker

With Docker installed, a readymade image can be fetched from the [GitHub Action](https://github.com/TEIC/TEIGarage/blob/main/.github/workflows/docker.yml).

`docker pull ghcr.io/teic/teigarage:latest`

```bash
docker run --rm \
    -p 8080:8080 \   
    -e WEBSERVICE_URL=http://localhost:8080/ege-webservice/  \
    --name teigarage ghcr.io/teic/teigarage
```

Once it's running, you can point your browser at `http://localhost:8080/ege-webservice` for the webservice.

### available parameters

* **WEBSERVICE_URL** : The full URL of the RESTful *web service*. This is relevant for the *web client* (aka the GUI) if you are running the docker container on a different port or with a different URL.

* **-v** Stylesheet paths : The local path to the stylesheets and sources can be mounted to /usr/share/xml/tei/ using the --volume parameter, using e.g.  `-v /your/path/to/Stylesheets:/usr/share/xml/tei/stylesheet \ 
    -v /your/path/to/TEI/P5:/usr/share/xml/tei/odd`

### TEI sources and stylesheets

When the docker image is build, the latest releases of the TEI Sources and Stylesheets are added to the image.

If you want to use another version of the sources or stylesheets, you can mount the local folders where your custom files are located when running the Docker image. 

There are several ways to obtain these (see "Get and install a local copy" at http://www.tei-c.org/Guidelines/P5/), 
one of them is to download the latest release of both 
[TEI](https://github.com/TEIC/TEI/releases) and [Stylesheets](https://github.com/TEIC/Stylesheets/releases) from GitHub. 
Then, the Stylesheets' root directory (i.e. which holds the `profiles` directory) must be mapped to `/usr/share/xml/tei/stylesheet` whereas for the 
P5 sources you'll need to find the subdirectory which holds the file `p5subset.xml` and map this to `/usr/share/xml/tei/odd`; (should be `xml/tei/odd`).

The respective git repositories:

| location in docker image | data located there |
| --------------- | --------------- | 
| /usr/share/xml/tei/stylesheet |  https://github.com/TEIC/Stylesheets/releases/latest | 
| /usr/share/xml/tei/odd | https://github.com/TEIC/TEI/releases/latest |

Using your local folders for the TEI sources and stylesheets: 

```bash
docker run --rm \
    -p 8080:8080 \   
    -e WEBSERVICE_URL=http://localhost:8080/ege-webservice/  \  
    -v /your/path/to/tei/stylesheet:/usr/share/xml/tei/stylesheet \
    -v /your/path/to/tei/odd:/usr/share/xml/tei/odd  \    
    --name teigarage ghcr.io/teic/teigarage
```

You can also change the version that is used by supplying different version number when building the image locally running something like

```bash
docker build \
--build-arg VERSION_STYLESHEET=7.52.0 \
--build-arg VERSION_ODD=4.3.0 \
.
```

in your local copy of the TEIGarage. 
  
### exposed ports

The Docker image exposes two ports, 8080 and 8081. If you're running TEIGarage over plain old HTTP, use the 8080 connector. 
For HTTPS connections behind a 
[SSL terminating Load Balancer](https://creechy.wordpress.com/2011/08/22/ssl-termination-load-balancers-java/), please use the 8081 connector.

## Installing without Docker

### Getting the application packages

The latest released application package (WAR file) is available from the [TEIGarage release page](https://github.com/TEIC/TEIGarage/releases). 
The latest dev version can be downloaded via [nightly.link](https://nightly.link/) from the [GitHub Action](https://github.com/TEIC/TEIGarage/blob/main/.github/workflows/maven.yml) at [nightly.link/TEIC/TEIGarage/workflows/maven/main/artifact.zip](https://nightly.link/TEIC/TEIGarage/workflows/maven/main/artifact.zip).

The war file could also be build locally, see [Building with Maven](#building-with-maven). 

### Running the application packages

Using a running Tomcat (or similar container), you can install the WAR file (see above) in the usual way. In this case, you will need to do some configuration manually:

 1.   copy the file [TEIGarage/WEB-INF/lib/oxgarage.properties](https://github.com/TEIC/TEIGarage/blob/main/src/main/webapp/WEB-INF/lib/oxgarage.properties) to `/etc/oxgarage.properties`
 2.   create a directory `/var/cache/oxgarage` and copy the file [log4j.xml](https://github.com/TEIC/TEIGarage/blob/main/log4j.xml) to there
 3.   make the directory owned by the Tomcat user, so that it can create files there: eg `chown -R tomcat6:tomcat6 /var/cache/oxgarage`
 4.   make sure the TEI stylesheets and source are installed at `/usr/share/xml/tei` using the Debian file hierarchy standard; the distribution files mentioned in the [TEI sources and stylesheets](#tei-sources-and-stylesheets) are in the correct layout.

You'll probably need to restart your servlet container to make sure these changes take effect.

Edit the file `oxgarage.properties` if you need to change the names of directories.

Check the working system by visiting /ege-webclient/ on your Tomcat (or similar) server, and trying an example transformation. You can check the RESTful web server using e.g. Curl. For example, to convert a TEI file to Word docx format, you might do

```bash
curl -s -o test.docx -F upload=@test.xml http://localhost:8080/ege-webservice/Conversions/TEI%3Atext%3Axml/docx%3Aapplication%3Avnd.openxmlformats-officedocument.wordprocessingml.document
```

# Building with Maven

The TEIGarage Java project can be built with Maven using

`mvn -B package --file pom.xml`

Readymade .war files can be downloaded from the [GitHub Action using nightly.link](https://nightly.link/TEIC/TEIGarage/workflows/maven/main/artifact.zip)

## dependencies

The dependencies needed for the Maven build that are not available at the main [Maven repository](https://mvnrepository.com/) are available through GitHub Packages at the [TEIC](https://github.com/orgs/TEIC/packages) and [Edirom](https://github.com/orgs/Edirom/packages) GitHub organizations. While those packages are public, [GitHub authentication](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-apache-maven-registry#installing-a-package) is needed to access those packages.

To authenticate when building locally, create a [GitHub PAT](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) with the read:packages scope. Create a maven settings file or edit an existing one and add it to your .m2 folder (e.g. at /home/name/.m2)

```xml
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                      http://maven.apache.org/xsd/settings-1.0.0.xsd">

  <activeProfiles>
    <activeProfile>github</activeProfile>
  </activeProfiles>

  <profiles>
    <profile>
      <id>github</id>
      <repositories>
        <repository>
          <id>central</id>
          <url>https://repo1.maven.org/maven2</url>
        </repository>
        <repository>
          <id>githubtei</id>
          <url>https://maven.pkg.github.com/TEIC/*</url>
          <snapshots>
            <enabled>true</enabled>
          </snapshots>
        </repository>
      </repositories>
    </profile>
  </profiles>

  <servers>
    <server>
      <id>githubtei</id>
      <username>YOURGITHUBUSERNAME</username>
      <password>YOURGITHUBPAT</password>
    </server>
  </servers>
</settings>

```

