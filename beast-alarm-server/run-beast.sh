#!/bin/bash
source /scripts/beast.env

# Temporary data file
DATA=/tmp/${PROGRAM}.$$

# Launching options
OPT="-data ${DATA} -pluginCustomization ${ALARM_FOLDER}/${ALARM_VERSION}/configuration/LNLS-CON.ini -consoleLog -vmargs -Djava.awt.headless=true -Xms64m -Xmx256m -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap"

### Changes EPICS settings

# Updates list of hosts
sed -i "s:org.csstudio.platform.libs.epics/addr_list=.*$:org.csstudio.platform.libs.epics/addr_list=${EPICS_CA_ADDR_LIST}:" ${ALARM_FOLDER}/${ALARM_VERSION}/configuration/LNLS-CON.ini

echo ${EPICS_CA_AUTO_ADDR_LIST}

# Updates automatic search of epics variables
if [ "${EPICS_CA_AUTO_ADDR_LIST}" = "NO" ] ; then

	sed -i "s:org.csstudio.platform.libs.epics/auto_addr_list=.*$:org.csstudio.platform.libs.epics/auto_addr_list=false:" ${ALARM_FOLDER}/${ALARM_VERSION}/configuration/LNLS-CON.ini
else

	sed -i "s:org.csstudio.platform.libs.epics/auto_addr_list=.*$:org.csstudio.platform.libs.epics/auto_addr_list=true:" ${ALARM_FOLDER}/${ALARM_VERSION}/configuration/LNLS-CON.ini
fi

# Waits for database and ActiveMQ to be ready before lauching server
pushd /opt/wait-for-it/
	echo "Waiting for ActiveMQ"
	./wait-for-it.sh -t 0 -p 61616 -h ${ACTIVEMQ_HOST}
popd

pg_isready -h ${POSTGRESQL_HOST} -p ${POSTGRESQL_PORT}
PG_READY=$?
while [  ${PG_READY} -ne 0 ]; do
	pg_isready -h ${POSTGRESQL_HOST} -p ${POSTGRESQL_PORT}
	PG_READY=$?
	sleep 1
done

# Launches server
echo Launching ${ALARM_FOLDER}/${ALARM_VERSION}/AlarmServer ${OPT} 2>&1
${ALARM_FOLDER}/${ALARM_VERSION}/AlarmServer ${OPT} 2>&1
