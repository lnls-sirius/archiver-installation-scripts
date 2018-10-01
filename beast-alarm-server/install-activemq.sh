#!/bin/bash
if [ ! -d /scripts ]; then
    mkdir -p /scripts
fi

cp activemq.env /scripts/activemq.env
source /scripts/activemq.env

pushd docker-alarm-activemq

mkdir -p ${SCRIPT_FOLDER}/scripts/

# Update image and install required packages
sudo apt-get -y update && \
 apt-get install -y activemq

cp activemq-start \
     ${SCRIPT_FOLDER}/scripts/activemq-start

mkdir -p /etc/activemq/instances-enabled/main

# Copy activemq configuration file into the image
cp activemq.xml /etc/activemq/instances-enabled/main/activemq.xml

popd
