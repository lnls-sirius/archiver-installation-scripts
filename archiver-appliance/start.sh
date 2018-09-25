#!/bin/bash
source envs.sh


export JAVA_OPTS="-XX:MaxPermSize=128M -XX:+UseG1GC -Xmx4G -Xms4G -ea"

echo JAVA_HOME=$JAVA_HOME
echo JAVA_OPTS=$JAVA_OPTS
echo LDAP=$USE_AUTHENTICATION
echo SSL=$USE_AUTHENTICATION

function startTomcatAtLocation() { 
    if [ -z "$1" ]; then echo "startTomcatAtLocation called without any arguments"; exit 1; fi
    export CATALINA_BASE=$1
    echo "Starting tomcat at location ${CATALINA_BASE}"
    
    ARCH=`uname -m`
    if [[ $ARCH == 'x86_64' || $ARCH == 'amd64' ]]
    then
      echo "Using 64 bit versions of libraries"
      export LD_LIBRARY_PATH=${CATALINA_BASE}/webapps/engine/WEB-INF/lib/native/linux-x86_64:${LD_LIBRARY_PATH}
    else
      echo "Using 32 bit versions of libraries"
      export LD_LIBRARY_PATH=${CATALINA_BASE}/webapps/engine/WEB-INF/lib/native/linux-x86:${LD_LIBRARY_PATH}
    fi
    
    pushd ${CATALINA_BASE}/logs
    ${CATALINA_HOME}/bin/jsvc \
        -server \
        -cp ${CATALINA_HOME}/bin/bootstrap.jar:${CATALINA_HOME}/bin/tomcat-juli.jar \
        ${JAVA_OPTS} \
        -Dcatalina.base=${CATALINA_BASE} \
        -Dcatalina.home=${CATALINA_HOME} \
        -cwd ${CATALINA_BASE}/logs \
        -outfile ${CATALINA_BASE}/logs/catalina.out \
        -errfile ${CATALINA_BASE}/logs/catalina.err \
        -pidfile ${CATALINA_BASE}/pid \
        org.apache.catalina.startup.Bootstrap start
     popd
}

function stopTomcatAtLocation() { 
    if [ -z "$1" ]; then echo "stopTomcatAtLocation called without any arguments"; exit 1; fi
    export CATALINA_BASE=$1
    echo "Stopping tomcat at location ${CATALINA_BASE}"
    pushd ${CATALINA_BASE}/logs
    ${CATALINA_HOME}/bin/jsvc \
        -server \
        -cp ${CATALINA_HOME}/bin/bootstrap.jar:${CATALINA_HOME}/bin/tomcat-juli.jar \
        ${JAVA_OPTS} \
        -Dcatalina.base=${CATALINA_BASE} \
        -Dcatalina.home=${CATALINA_HOME} \
        -cwd ${CATALINA_BASE}/logs \
        -outfile ${CATALINA_BASE}/logs/catalina.out \
        -errfile ${CATALINA_BASE}/logs/catalina.err \
        -pidfile ${CATALINA_BASE}/pid \
        -stop \
        org.apache.catalina.startup.Bootstrap 
     popd
}

function stop() { 
	stopTomcatAtLocation ${CATALINA_HOME}/engine
	stopTomcatAtLocation ${CATALINA_HOME}/retrieval
	stopTomcatAtLocation ${CATALINA_HOME}/etl
	stopTomcatAtLocation ${CATALINA_HOME}/mgmt
}

function start() {
	# Waits for MySQL database to start
	echo Waiting for MySQL to start at ${MYSQL_ADDRESS}:3306 ...
	chmod +x ${APPLIANCE_FOLDER}/build/configuration/wait-for-it/wait-for-it.sh
	${APPLIANCE_FOLDER}/build/configuration/wait-for-it/wait-for-it.sh ${MYSQL_ADDRESS}:3306
 
	startTomcatAtLocation ${CATALINA_HOME}/mgmt
	startTomcatAtLocation ${CATALINA_HOME}/engine
	startTomcatAtLocation ${CATALINA_HOME}/etl
	startTomcatAtLocation ${CATALINA_HOME}/retrieval
}


# See how we were called.
case "$1" in
  start)
	start
	;;
  stop)
	stop
	;;
  restart)
	stop
	start
	;;
  *)
	echo $"Usage: $0 {start|stop|restart}"
	exit 2
esac
