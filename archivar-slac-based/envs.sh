#!/bin/bash

export APPLIANCE_ADDRESS="127.0.0.1"
export ARCHAPPL_MYIDENTITY="lnls_appliance_1"
export APPLIANCES_NAME="lnls_appliances.xml"
export POLICIES_NAME="lnls_policies.py"

ARCH='x86_64'

TOMCAT_USERNAME=admin
TOMCAT_PASSWORD=admin

export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
export JAVA_OPTS="-XX:MaxPermSize=128M -XX:+UseG1GC -Xmx8G -Xms8G -ea"
export PATH=${JAVA_HOME}/bin:$PATH

VIEWER_DEV=false
if [ ${VIEWER_DEV} = false ]; then
    export ARCHIVER_VIEWER_REPO="https://github.com/lnls-sirius/archiver-viewer.git"
else
    export ARCHIVER_VIEWER_REPO="https://github.com/carneirofc/archiver-viewer.git"
fi

APPLIANCE_STORAGE_FOLDER=/epics-archiver-storage
ARCHAPPL_SHORT_TERM_FOLDER=${APPLIANCE_STORAGE_FOLDER}/sts
ARCHAPPL_MEDIUM_TERM_FOLDER=${APPLIANCE_STORAGE_FOLDER}/mts
ARCHAPPL_LONG_TERM_FOLDER=${APPLIANCE_STORAGE_FOLDER}/lts

mkdir -p ${ARCHAPPL_SHORT_TERM_FOLDER}
mkdir -p ${ARCHAPPL_MEDIUM_TERM_FOLDER}
mkdir -p ${ARCHAPPL_LONG_TERM_FOLDER}

# We assume that we inherit the EPICS environment variables 
# This includes setting up the LD_LIBRARY_PATH to include the JCA .so file. 

# LD_LIBRARY_PATH should have the EPICS 
export LD_LIBRARY_PATH=${EPICS_BASE}/lib/${EPICS_HOST_ARCH}:${LD_LIBRARY_PATH}
export PATH=${EPICS_BASE}/bin/${EPICS_HOST_ARCH}:${PATH}


export TOMCAT_DISTRIBUTION=apache-tomcat-9.0.12
export TOMCAT_URL="http://ftp.unicamp.br/pub/apache/tomcat/tomcat-9/v9.0.12/bin/${TOMCAT_DISTRIBUTION}.tar.gz"
export TOMCAT_NATIVE_DISTRIBUTION=tomcat-native-1.2.17-src
export TOMCAT_NATIVE_URL="http://mirror.nbtelecom.com.br/apache/tomcat/tomcat-connectors/native/1.2.17/source/${TOMCAT_NATIVE_DISTRIBUTION}.tar.gz"

# Não utilizar versões mais recentes do connector pois irá quebrar a appliance !
export MYSQL_CONNECTOR=mysql-connector-java-5.1.41
export ARCHIVER_REPO=https://github.com/slacmshankar/epicsarchiverap.git

