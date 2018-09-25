#!/bin/sh

#
# A simple script to start tomcat service. This script blocks and does not
# allow the container to finish and end.
#

trap cleanup EXIT 

cleanup(){
  echo "Stopping Tomcat"
    for APPLIANCE_UNIT in "engine" "retrieval" "etl" "mgmt"
    do
        export CATALINA_BASE=${CATALINA_HOME}/${APPLIANCE_UNIT}
        echo ${CATALINA_BASE} stop
        ${CATALINA_HOME}/bin/catalina.sh stop
    done
    echo "Bye !"
    exit 1
}

# Waits for MySQL database to start
chmod +x ${APPLIANCE_FOLDER}/build/configuration/wait-for-it/wait-for-it.sh
${APPLIANCE_FOLDER}/build/configuration/wait-for-it/wait-for-it.sh ${MYSQL_ADDRESS}:3306

# Setup all appliances
/bin/bash ${APPLIANCE_FOLDER}/build/scripts/setup-appliance.sh

for APPLIANCE_UNIT in "engine" "retrieval" "etl" "mgmt"
do
    export CATALINA_BASE=${CATALINA_HOME}/${APPLIANCE_UNIT}
    ${CATALINA_HOME}/bin/catalina.sh start
    echo ${CATALINA_BASE}  start  
done

tail -f /dev/null