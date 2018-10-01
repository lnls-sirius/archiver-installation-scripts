#!/bin/bash
if [ ! -d /scripts ]; then
    mkdir -p /scripts
fi

cp beast.env /scripts/beast.env
source /scripts/beast.env

pushd docker-alarm-server

    # Update image and install required packages
    sudo apt-get update && apt-get install -y git maven openjdk-8-jdk postgresql-client

    # create new folder and copy all scripts
    mkdir -p ${ALARM_FOLDER}/build/scripts/
    
    cp scripts/setup-beast.sh ${ALARM_FOLDER}/build/scripts/setup-beast.sh

    # Clone and compile alarm source code
    pushd ${ALARM_FOLDER}/build/scripts/
        . ./setup-beast.sh
    popd

    # Copy provided configuration file
    # cp configuration/LNLS-CON.ini ${ALARM_FOLDER}/${ALARM_VERSION}/configuration/LNLS-CON.ini
    cp ../LNLS-CON.ini ${ALARM_FOLDER}/${ALARM_VERSION}/configuration/LNLS-CON.ini

    mkdir -p ${ALARM_FOLDER}/${ALARM_VERSION}/scripts

    mkdir -p ${ALARM_FOLDER}/${ALARM_VERSION}/log

    mkdir -p ${ALARM_FOLDER}/${ALARM_VERSION}/scripts/wait-for-it

    if [ ! -d /opt/wait-for-it ]; then
        pushd /opt/
            git clone https://github.com/vishnubob/wait-for-it.git
        popd
    fi

    cp scripts/start-beast.sh ${ALARM_FOLDER}/${ALARM_VERSION}/scripts

    echo "Beast Alarm Server Installed !"

popd
