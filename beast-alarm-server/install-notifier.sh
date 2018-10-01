#!/bin/bash
if [ ! -d /scripts ]; then
    mkdir -p /scripts
fi

cp alarm-notifier.env /scripts/alarm-notifier.env
source alarm-notifier.env

# Update image and install required packages
apt-get -y update && apt-get install -y git maven postgresql-client

pushd docker-alarm-server-notifier

    cp setup-notifier.sh ${ALARM_NOTIFIER_FOLDER}/build/scripts/

    # Clone and compile alarm source code
    source ${ALARM_NOTIFIER_FOLDER}/build/scripts/setup-notifier.sh

    # create new folder and copy all scripts
    mkdir -p ${ALARM_NOTIFIER_FOLDER}/build/scripts/
        
    # Copy provided configuration file
    mkdir -p ${ALARM_NOTIFIER_FOLDER}/${ALARM_NOTIFIER_VERSION}/configuration
    
    cp ../LNLS-CON.ini ${ALARM_NOTIFIER_FOLDER}/${ALARM_NOTIFIER_VERSION}/configuration/LNLS-CON.ini

popd

