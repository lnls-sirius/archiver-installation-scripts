#!/bin/bash

export ARCH='x86_64'

# Installation Options
export USE_PKG=true

# JVM options
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH=${JAVA_HOME}/bin:$PATH
export JAVA_OPTS="-XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap"
 
export CATALINA_HOME=/opt/tomcat
export TOMCAT_HOME=${CATALINA_HOME}
export PATH=${CATALINA_HOME}/bin:$PATH

export TOMCAT_DISTRIBUTION=apache-tomcat-9.0.12
export TOMCAT_URL="http://ftp.unicamp.br/pub/apache/tomcat/tomcat-9/v9.0.12/bin/${TOMCAT_DISTRIBUTION}.tar.gz"
export TOMCAT_NATIVE_DISTRIBUTION=tomcat-native-1.2.17-src
export TOMCAT_NATIVE_URL="http://mirror.nbtelecom.com.br/apache/tomcat/tomcat-connectors/native/1.2.17/source/${TOMCAT_NATIVE_DISTRIBUTION}.tar.gz"

export APR_DISTRIBUTION=apr-1.6.3
export APR_URL="http://ftp.unicamp.br/pub/apache//apr/${APR_DISTRIBUTION}.tar.gz"
export APR_DIR=/usr/local/apr

export OPENSSL_DISTRIBUTION=openssl-1.1.1
export OPENSSL_URL="https://www.openssl.org/source/${OPENSSL_DISTRIBUTION}.tar.gz"
export OPENSSL_DIR=/usr/local/ssl

export LD_LIBRARY_PATH=${CATALINA_HOME}/lib:${LD_LIBRARY_PATH}

export APPLIANCE_NAME=epics-archiver-appliances
export APPLIANCE_FOLDER=/opt/${APPLIANCE_NAME}
export APPLIANCE_STORAGE_FOLDER=/opt/epics-archiver-storage

export TOMCAT_PASSWORD=admin
export TOMCAT_USERNAME=admin


# General EPICS Archiver Appliance Setup
export ARCHAPPL_SITEID=lnls-control-archiver
export ARCHAPPL_MYIDENTITY=lnls_control_appliance_1

export ARCHAPPL_APPLIANCES=${APPLIANCE_FOLDER}/configuration/lnls_appliances.xml
export ARCHAPPL_POLICIES=${APPLIANCE_FOLDER}/configuration/lnls_policies.py


export ARCHAPPL_SHORT_TERM_FOLDER=${APPLIANCE_STORAGE_FOLDER}/sts
export ARCHAPPL_MEDIUM_TERM_FOLDER=${APPLIANCE_STORAGE_FOLDER}/mts
export ARCHAPPL_LONG_TERM_FOLDER=${APPLIANCE_STORAGE_FOLDER}/lts

export APPLIANCE_ADDRESS=localhost

export CERTIFICATE_PASSWORD=changeit

# ldap-login or not 
export USE_AUTHENTICATION=false

# MySQL Related
export MYSQL_USER=user_archappl
export MYSQL_PASSWORD=archappl
export MYSQL_DATABASE=archappl
export MYSQL_PORT=3306
export MYSQL_ADDRESS=localhost

# Set up mysql connector
export MYSQL_CONNECTOR=mysql-connector-java-5.1.41

# Github repository variables
export GITHUB_REPOSITORY_FOLDER=/opt/epicsarchiverap-ldap
export SLAC_DISTRO=true
if [ ${SLAC_DISTRO} = false ]; then
    export GITHUB_REPOSITORY_URL=https://github.com/lnls-sirius/epicsarchiverap-ldap.git 

    # LDAP environment variables
    export CONNECTION_URL=ldap://10.0.6.51:389
    export CONNECTION_USER_FILTER=(cn={0})
    export CONNECTION_USER_BASE=ou=users,dc=lnls,dc=br
    export CONNECTION_NAME=**bind_dn_name**
    export CONNECTION_PASSWORD=**bind_dn_passwd**
    export CONNECTION_ROLE_BASE=ou=epics-archiver,ou=groups,dc=lnls,dc=br
    export CONNECTION_ROLE_NAME=cn
    export CONNECTION_ROLE_SEARCH=(member={0})
else
    export GITHUB_REPOSITORY_URL=https://github.com/slacmshankar/epicsarchiverap.git
fi

# EPICS environment variables
export EPICS_CA_ADDR_LIST=10.0.6.57
export EPICS_CA_AUTO_ADDR_LIST=NO
export EPICS_CA_MAX_ARRAY_BYTES=100000000



# Timezone
export TZ=America/Sao_Paulo

# Log4j Debug
export LOG4J_DEBUG=true

# EPICS environment variables
export EPICS_BASE_VERSION=3.15.5
export EPICS_BASE_NAME=epics-${EPICS_BASE_VERSION} 

export EPICS_HOST_ARCH=linux-x86_64 
export EPICS_BASE=/opt/epics-R3.15.5/base
export PATH=${EPICS_BASE}/bin/${EPICS_HOST_ARCH}:$PATH
 