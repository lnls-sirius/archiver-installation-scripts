#!/bin/bash
source /scripts/alarm-notifier.env
source /scripts/beast.env

# Temporary data file
DATA=/tmp/${PROGRAM}.$$

# Launching options
OPT="-data ${DATA} -pluginCustomization ${ALARM_NOTIFIER_FOLDER}/${ALARM_NOTIFIER_VERSION}/configuration/LNLS-CON.ini -consoleLog -vmargs -Djava.awt.headless=true"

### Changes EPICS settings
# Updates smtp host
if [ ${SMTP_HOST+x} ]; then
    sed -i "s:org.csstudio.email/smtp_host=.*$:org.csstudio.email/smtp_host=${SMTP_HOST}:" ${ALARM_NOTIFIER_FOLDER}/${ALARM_NOTIFIER_VERSION}/configuration/LNLS-CON.ini
fi

if [ ${SMTP_SENDER+x} ]; then
    sed -i "s:org.csstudio.email/smtp_sender=.*$:org.csstudio.email/smtp_sender=${SMTP_SENDER}:" ${ALARM_NOTIFIER_FOLDER}/${ALARM_NOTIFIER_VERSION}/configuration/LNLS-CON.ini
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
${ALARM_NOTIFIER_FOLDER}/${ALARM_NOTIFIER_VERSION}/AlarmNotifier ${OPT} 2>&1
