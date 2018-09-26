#!/bin/bash

# Zenith Stuff ...
# resizes the window to full height and 50% width and moves into upper right corner

#define the height in px of the top system-bar:
TOPMARGIN=27

#sum in px of all horizontal borders:
RIGHTMARGIN=10

# get width of screen and height of screen
SCREEN_WIDTH=$(xwininfo -root | awk '$1=="Width:" {print $2}')

# new width and height
W=$(( $SCREEN_WIDTH / 2 - $RIGHTMARGIN ))

# Load Envs !
source envs.sh

function check_mysql(){
# If we are here, the MYSQL_CONNECTION_STRING is valid.
# Let's check to see if the tables exist.
MYSQL_CONNECTION_STRING="--user=${MYSQL_USER} --password=${MYSQL_PASSWORD} --database=${MYSQL_DATABASE}"
mysql ${MYSQL_CONNECTION_STRING} -e "SHOW TABLES" | grep PVTypeInfo
if (( ( $? != 0 ) ))
then
	MSG="I do not see the PVTypeInfo table in ${MYSQL_CONNECTION_STRING}? Should we go ahead and create the tables? This step will delete any old data that you have."
	echo ${MSG}
	zenity --text="${MSG}" --question --width=$W --height=150

	if [[ $? == 0 ]] ; then
		echo "Creating tables in ${MYSQL_CONNECTION_STRING}"
		mysql ${MYSQL_CONNECTION_STRING} < archappl_mysql.sql
		
		mysql ${MYSQL_CONNECTION_STRING} -e "SHOW TABLES" | grep PVTypeInfo
		if (( ( $? != 0 ) ))
		then
			MSG="Cannot create the MySQL tables. Do you have the right permissions?"
			echo ${MSG}
			zenity --text="${MSG}" --error --width=$W --height=150
			exit 1
		fi
	else
		echo "Skipping creating MySQL tables."
	fi
else 
	MSG="The EPICS archiver appliance tables already exist in the schema accessed by using ${MYSQL_CONNECTION_STRING}"
	echo ${MSG}
	zenity --text="${MSG}" --info	--width=$W --height=150
fi
}

# Install required packages
apt-get install -y \
    ant gcc git g++ \
    libreadline-dev \
    make openjdk-8-jdk \
    perl tar xmlstarlet wge 

wd=$(pwd)

# Install Apache Tomcat 
if [ -d "$CATALINA_HOME" ]; then
    # @todo: remover o tomcat  direito ! (parando serviços e tal ...)
    rm -rd ${CATALINA_HOME}
fi

wget ${TOMCAT_URL} -P ${CATALINA_HOME}
tar -C ${CATALINA_HOME} -zxf ${CATALINA_HOME}/${TOMCAT_DISTRIBUTION}.tar.gz
rm ${CATALINA_HOME}/${TOMCAT_DISTRIBUTION}.tar.gz
mv -v ${CATALINA_HOME}/${TOMCAT_DISTRIBUTION}/* ${CATALINA_HOME}/
rm -d ${CATALINA_HOME}/${TOMCAT_DISTRIBUTION}


# Installing dependencies
if [ "${USE_PKG}" = true ]; then
    echo Using apt-get for dependencies
    # OpenSSL
    apt-get -y install openssl
    # APR Install 
    apt-get install -y apache2-dev libapr1 libapr1-dev libaprutil1-dev
else
    echo Building dependencies from source
    ./dependencies-build.sh
fi

# Build the Apache Commons Daemon that ships with Tomcat
echo Building the Apache Commons Daemon that ships with Tomcat
pushd ${CATALINA_HOME}/bin
tar zxf commons-daemon-native.tar.gz
COMMONS_DAEMON_VERSION_FOLDER=`ls -d commons-daemon-*-native-src | head -1`
popd

pushd ${CATALINA_HOME}/bin/${COMMONS_DAEMON_VERSION_FOLDER}/unix
./configure
make
if [[ ! -f jsvc ]]
then
        MSG="Cannot seem to build Apache Commons demon in ${CATALINA_HOME}/bin/${COMMONS_DAEMON_VERSION_FOLDER}/unix"
        echo ${MSG} 
        exit 1
fi
popd
cp ${CATALINA_HOME}/bin/${COMMONS_DAEMON_VERSION_FOLDER}/unix/jsvc ${CATALINA_HOME}/bin

# Appliance
if [[ ${APPLIANCE_STORAGE_FOLDER} = *${APPLIANCE_FOLDER}* ]]; then
    echo You shoud choose a storage folder that is outside the appliance folder
else
    if [ -d "$APPLIANCE_FOLDER" ]; then
        rm -rd ${APPLIANCE_FOLDER}
    fi
fi

if [ ! -d "${APPLIANCE_FOLDER}/build/scripts" ]; then
    mkdir -p ${APPLIANCE_FOLDER}/build/scripts
fi

# Clone archiver github's repository
git clone ${GITHUB_REPOSITORY_URL} ${GITHUB_REPOSITORY_FOLDER}

mkdir -p ${APPLIANCE_FOLDER}/build/bin

# MySQL Connector
wget -P ${APPLIANCE_FOLDER}/build/bin https://dev.mysql.com/get/Downloads/Connector-J/${MYSQL_CONNECTOR}.tar.gz --no-check-certificate
tar -C ${APPLIANCE_FOLDER}/build/bin -xvf ${APPLIANCE_FOLDER}/build/bin/${MYSQL_CONNECTOR}.tar.gz
cp ${APPLIANCE_FOLDER}/build/bin/${MYSQL_CONNECTOR}/${MYSQL_CONNECTOR}-bin.jar ${CATALINA_HOME}/lib/
rm -R ${APPLIANCE_FOLDER}/build/bin/${MYSQL_CONNECTOR}

# Appliance Configuration and Storage
mkdir -p ${APPLIANCE_FOLDER}/configuration
mkdir -p ${ARCHAPPL_BASE_STORAGE}

cp lnls_appliances.xml ${ARCHAPPL_APPLIANCES}
cp lnls_policies.py ${ARCHAPPL_POLICIES}
 
mkdir -p ${ARCHAPPL_SHORT_TERM_FOLDER}
mkdir -p ${ARCHAPPL_MEDIUM_TERM_FOLDER}
mkdir -p ${ARCHAPPL_LONG_TERM_FOLDER}

# Wait MySQL Server
mkdir -p ${APPLIANCE_FOLDER}/build/configuration/wait-for-it
git clone https://github.com/vishnubob/wait-for-it.git ${APPLIANCE_FOLDER}/build/configuration/wait-for-it

# Waits for MySQL database to start
chmod +x ${APPLIANCE_FOLDER}/build/configuration/wait-for-it/wait-for-it.sh
/bin/bash ${APPLIANCE_FOLDER}/build/configuration/wait-for-it/wait-for-it.sh ${MYSQL_ADDRESS}:3306

check_mysql 

cp setup-appliance.sh ${APPLIANCE_FOLDER}/build/scripts/
cp tomcat-service.sh ${APPLIANCE_FOLDER}/build/scripts/
 
cp configuration/context.xml ${CATALINA_HOME}/conf/context.xml


# Change all addresses in lnls_appliances.xml and context.xml
sed -i "s/APPLIANCE_ADDRESS/${APPLIANCE_ADDRESS}/g" ${ARCHAPPL_APPLIANCES}
sed -i "s/ARCHAPPL_MYIDENTITY/${ARCHAPPL_MYIDENTITY}/g" ${ARCHAPPL_APPLIANCES}

if [ ${USE_AUTHENTICATION} = false]; then
    sed -i "s/<mgmt_url>https/<mgmt_url>http/g" ${CATALINA_HOME}/conf/context.xml
fi

sed -i "s/MYSQL_USER/${MYSQL_USER}/g" ${CATALINA_HOME}/conf/context.xml
sed -i "s/MYSQL_PASSWORD/${MYSQL_PASSWORD}/g" ${CATALINA_HOME}/conf/context.xml
sed -i "s/MYSQL_DATABASE/${MYSQL_DATABASE}/g" ${CATALINA_HOME}/conf/context.xml

cat ${ARCHAPPL_APPLIANCES}
cat ${CATALINA_HOME}/conf/context.xml 

mkdir -p ${APPLIANCE_FOLDER}/build/cert/

# Setup all appliances
/bin/bash ${APPLIANCE_FOLDER}/build/scripts/setup-appliance.sh

