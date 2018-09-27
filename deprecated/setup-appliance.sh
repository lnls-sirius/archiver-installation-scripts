#!/bin/sh

RAND_SRV_PORT=16000

sed -i 's/username=.*$/username=\"'"${MYSQL_USER}"'\"/' ${CATALINA_HOME}/conf/context.xml
sed -i 's/password=.*$/password=\"'"${MYSQL_PASSWORD}"'\"/' ${CATALINA_HOME}/conf/context.xml
sed -i 's/url=.*$/url=\"jdbc:mysql:\/\/'"${MYSQL_ADDRESS}"':'"${MYSQL_PORT}"'\/'"${MYSQL_DATABASE}"'\"/' ${CATALINA_HOME}/conf/context.xml

# For debugging
if [ "${USE_AUTHENTICATION}" = true ]; then
    echo Using authentication ...
    sed -i "s:INFO:ALL:g" ${GITHUB_REPOSITORY_FOLDER}/src/sitespecific/lnls-control-archiver/classpathfiles/log4j.properties
fi

# Choose wich branch will be used
if [ "${USE_AUTHENTICATION}" = true ]; then
    echo "Using ldap"
    GITHUB_APPLIANCES_BRANCH=${GITHUB_APPLIANCES_BRANCH:-ldap-login}
else 
    GITHUB_APPLIANCES_BRANCH=${GITHUB_APPLIANCES_BRANCH:-master}
fi

(cd ${GITHUB_REPOSITORY_FOLDER}; git config user.email "controle@lnls.br"; git config user.name "Controls Group"; git fetch origin ${GITHUB_APPLIANCES_BRANCH}; git checkout ${GITHUB_APPLIANCES_BRANCH})

for APPLIANCE_UNIT in "mgmt" "engine" "retrieval" "etl"
do

    APPLIANCE_PORT=$(xmlstarlet sel -t -v "/appliances/appliance[identity='${ARCHAPPL_MYIDENTITY}']/${APPLIANCE_UNIT}_url" ${ARCHAPPL_APPLIANCES} | sed "s/.*://" | sed "s/\/.*//" ) 

    mkdir -p ${CATALINA_HOME}/${APPLIANCE_UNIT}
    cp -r ${CATALINA_HOME}/conf ${CATALINA_HOME}/${APPLIANCE_UNIT}/conf
    cp -r ${CATALINA_HOME}/webapps ${CATALINA_HOME}/${APPLIANCE_UNIT}/webapps
    mkdir -p ${CATALINA_HOME}/${APPLIANCE_UNIT}/logs
    mkdir -p ${CATALINA_HOME}/${APPLIANCE_UNIT}/temp
    mkdir -p ${CATALINA_HOME}/${APPLIANCE_UNIT}/work

    sed -i "s:FINE:ALL:g" ${CATALINA_HOME}/${APPLIANCE_UNIT}/conf/logging.properties

    xmlstarlet ed -L -u '/Server/@port' -v ${RAND_SRV_PORT} ${CATALINA_HOME}/${APPLIANCE_UNIT}/conf/server.xml

    if [ "${APPLIANCE_UNIT}" = "engine" ] || [ "${APPLIANCE_UNIT}" = "etl" ] || [ "${APPLIANCE_UNIT}" = "retrieval" ]; then

            xmlstarlet ed -L -u "/appliances/appliance[identity='${ARCHAPPL_MYIDENTITY}']/${APPLIANCE_UNIT}_url" -v "http://${APPLIANCE_ADDRESS}:${APPLIANCE_PORT}/${APPLIANCE_UNIT}/bpl" ${ARCHAPPL_APPLIANCES}

            if [ "${APPLIANCE_UNIT}" = "retrieval" ]; then
                   xmlstarlet ed -L -u "/appliances/appliance[identity='${ARCHAPPL_MYIDENTITY}']/data_retrieval_url" -v "http://${APPLIANCE_ADDRESS}:${APPLIANCE_PORT}/${APPLIANCE_UNIT}" ${ARCHAPPL_APPLIANCES}
            fi

            # Appends new connector
            xmlstarlet ed -L -u "/Server/Service/Connector[@protocol='HTTP/1.1']/@port" -v ${APPLIANCE_PORT} ${CATALINA_HOME}/${APPLIANCE_UNIT}/conf/server.xml

            # Remove every other connector entry from the conf/server.xml
            xmlstarlet ed -L -d "/Server/Service/Connector[@protocol!='HTTP/1.1']" ${CATALINA_HOME}/${APPLIANCE_UNIT}/conf/server.xml

    elif [ "${APPLIANCE_UNIT}" = "mgmt" ]; then

            # Sets cluster inet port
            xmlstarlet ed -L -u "/appliances/appliance[identity='${ARCHAPPL_MYIDENTITY}']/cluster_inetport" -v "${APPLIANCE_ADDRESS}:12000" ${ARCHAPPL_APPLIANCES}
            if [ "${USE_AUTHENTICATION}" = true ]; then
                # Generates keystore
                keytool -genkey -alias tomcat -keyalg RSA -dname "CN=${APPLIANCE_ADDRESS}, OU=Controls Group, O=LNLS, L=Campinas, ST=Sao Paulo, C=BR" -storepass ${CERTIFICATE_PASSWORD} -keypass ${CERTIFICATE_PASSWORD} -keystore ${APPLIANCE_FOLDER}/build/cert/appliance-mgmt.keystore -validity 730

                # Copies keystore to conf/
                cp ${APPLIANCE_FOLDER}/build/cert/appliance-mgmt.keystore ${CATALINA_HOME}/conf/

                # Generates certificate
                keytool -exportcert -keystore ${CATALINA_HOME}/conf/appliance-mgmt.keystore -alias tomcat -storepass ${CERTIFICATE_PASSWORD} -file ${APPLIANCE_FOLDER}/build/cert/archiver-mgmt.crt
                
                # Imports certificate into trusted keystore
                keytool -import -alias tomcat -trustcacerts -storepass ${CERTIFICATE_PASSWORD} -noprompt -keystore $JAVA_HOME/jre/lib/security/cacerts -file ${APPLIANCE_FOLDER}/build/cert/archiver-mgmt.crt

                xmlstarlet ed -L -u "/appliances/appliance[identity='${ARCHAPPL_MYIDENTITY}']/${APPLIANCE_UNIT}_url" -v "https://${APPLIANCE_ADDRESS}:${APPLIANCE_PORT}/${APPLIANCE_UNIT}/bpl" ${ARCHAPPL_APPLIANCES}

                # Remove default connector port
                xmlstarlet ed -L -d "/Server/Service/Connector" ${CATALINA_HOME}/${APPLIANCE_UNIT}/conf/server.xml

                # Appends new connector
                xmlstarlet ed -L -s "/Server/Service" -t elem -n "Connector" \
                                 -i "/Server/Service/Connector" -t attr -n "protocol" -v "org.apache.coyote.http11.Http11NioProtocol" \
                                 -i "/Server/Service/Connector" -t attr -n "port" -v "${APPLIANCE_PORT}" \
                                 -i "/Server/Service/Connector" -t attr -n "redirectPort" -v "8443" \
                                 -i "/Server/Service/Connector" -t attr -n "maxThreads" -v "150" \
                                 -i "/Server/Service/Connector" -t attr -n "SSLEnabled" -v "true" \
                                 -i "/Server/Service/Connector" -t attr -n "scheme" -v "https" \
                                 -i "/Server/Service/Connector" -t attr -n "secure" -v "true" \
                                 ${CATALINA_HOME}/${APPLIANCE_UNIT}/conf/server.xml 

                 xmlstarlet ed -L -s '/Server/Service/Connector[@port='"${APPLIANCE_PORT}"']' -t elem -n "SSLHostConfig" ${CATALINA_HOME}/${APPLIANCE_UNIT}/conf/server.xml

                 cp ${APPLIANCE_FOLDER}/build/cert/appliance-mgmt.keystore ${CATALINA_HOME}/${APPLIANCE_UNIT}/conf

                 xmlstarlet ed -L -s '/Server/Service/Connector[@port='"${APPLIANCE_PORT}"']/SSLHostConfig' -t elem -n "Certificate" \
                                  -i '/Server/Service/Connector[@port='"${APPLIANCE_PORT}"']/SSLHostConfig/Certificate' -t attr -n "certificateKeystoreFile" -v "conf/appliance-mgmt.keystore" \
                                  -i '/Server/Service/Connector[@port='"${APPLIANCE_PORT}"']/SSLHostConfig/Certificate' -t attr -n "type" -v "RSA" \
                                  ${CATALINA_HOME}/${APPLIANCE_UNIT}/conf/server.xml

                 # Appends new realm
                 xmlstarlet ed -L -s '/Server/Service/Engine/Host' -t elem -n "Realm" \
                                  -i '/Server/Service/Engine/Host/Realm' -t attr -n "connectionURL" -v "${CONNECTION_URL}" \
                                  -i '/Server/Service/Engine/Host/Realm' -t attr -n "userSearch" -v "${CONNECTION_USER_FILTER}" \
                                  -i '/Server/Service/Engine/Host/Realm' -t attr -n "userSubtree" -v "true" \
                                  -i '/Server/Service/Engine/Host/Realm' -t attr -n "userBase" -v "${CONNECTION_USER_BASE}" \
                                  -i '/Server/Service/Engine/Host/Realm' -t attr -n "className" -v "org.apache.catalina.realm.JNDIRealm" \
                                  ${CATALINA_HOME}/${APPLIANCE_UNIT}/conf/server.xml

                 if [ ! -z ${ALTERNATIVE_URL+x} ]; then
                     xmlstarlet ed -L -i '/Server/Service/Engine/Host/Realm' -t attr -n "alternativeURL" -v "${ALTERNATIVE_URL}" \
                                      ${CATALINA_HOME}/${APPLIANCE_UNIT}/conf/server.xml
                 fi

                 if [ ! -z ${CONNECTION_ROLE_BASE+x} ]; then
                     xmlstarlet ed -L -i '/Server/Service/Engine/Host/Realm' -t attr -n "roleBase" -v "${CONNECTION_ROLE_BASE}" \
                                      -i '/Server/Service/Engine/Host/Realm' -t attr -n "roleSubtree" -v "true" \
                                      ${CATALINA_HOME}/${APPLIANCE_UNIT}/conf/server.xml
                 fi

                 if [ ! -z ${CONNECTION_ROLE_NAME+x} ]; then
                     xmlstarlet ed -L -i '/Server/Service/Engine/Host/Realm' -t attr -n "roleName" -v "${CONNECTION_ROLE_NAME}" ${CATALINA_HOME}/${APPLIANCE_UNIT}/conf/server.xml
                 fi

                 if [ ! -z ${CONNECTION_ROLE_SEARCH+x} ]; then
                     xmlstarlet ed -L -i '/Server/Service/Engine/Host/Realm' -t attr -n "roleSearch" -v "${CONNECTION_ROLE_SEARCH}" ${CATALINA_HOME}/${APPLIANCE_UNIT}/conf/server.xml
                 fi

                 if [ ! -z ${CONNECTION_NAME+x} ]; then
                     xmlstarlet ed -L -i '/Server/Service/Engine/Host/Realm' -t attr -n "connectionName" -v "${CONNECTION_NAME}" ${CATALINA_HOME}/${APPLIANCE_UNIT}/conf/server.xml
                 fi

                 if [ !	-z ${CONNECTION_PASSWORD+x} ]; then
                     xmlstarlet ed -L -i '/Server/Service/Engine/Host/Realm' -t attr -n "connectionPassword" -v "${CONNECTION_PASSWORD}" ${CATALINA_HOME}/${APPLIANCE_UNIT}/conf/server.xml
                 fi 

            else

                xmlstarlet ed -L -u "/appliances/appliance[identity='${ARCHAPPL_MYIDENTITY}']/${APPLIANCE_UNIT}_url" -v "http://${APPLIANCE_ADDRESS}:${APPLIANCE_PORT}/${APPLIANCE_UNIT}/bpl" ${ARCHAPPL_APPLIANCES}

                # Appends new connector
                xmlstarlet ed -L -u "/Server/Service/Connector[@protocol='HTTP/1.1']/@port" -v ${APPLIANCE_PORT} ${CATALINA_HOME}/${APPLIANCE_UNIT}/conf/server.xml

                # Remove every other connector entry from the conf/server.xml
                xmlstarlet ed -L -d "/Server/Service/Connector[@protocol!='HTTP/1.1']" ${CATALINA_HOME}/${APPLIANCE_UNIT}/conf/server.xml
            fi

	    # Changes viewer's url port
	    RETRIEVAL_PORT=$(xmlstarlet sel -t -v "/appliances/appliance[identity='${ARCHAPPL_MYIDENTITY}']/retrieval_url" ${ARCHAPPL_APPLIANCES} | sed "s/.*://" | sed "s/\/.*//" ) 
	    sed -i 's#var dataRetrievalURL = .*$#var dataRetrievalURL = window.location.port != "" \&\& window.location.port > 0 ? "http:" + window.location.href.split(":")[1] + ":'"${RETRIEVAL_PORT}"'/retrieval" :  "http://" + window.location.hostname + "/retrieval";#g' ${GITHUB_REPOSITORY_FOLDER}/src/main/org/epics/archiverappliance/mgmt/staticcontent/js/mgmt.js
    fi

    # Change wardest and dist properties in build.xml to ./
    xmlstarlet ed -L -u "/project/property[@name='wardest']/@location" -v "./" ${GITHUB_REPOSITORY_FOLDER}/build.xml
    xmlstarlet ed -L -u "/project/property[@name='dist']/@location" -v "./" ${GITHUB_REPOSITORY_FOLDER}/build.xml

    # Build only specific war file
    export TOMCAT_HOME=${CATALINA_HOME}
    (cd ${GITHUB_REPOSITORY_FOLDER}; ant ${APPLIANCE_UNIT}_war)

    mkdir ${CATALINA_HOME}/${APPLIANCE_UNIT}/webapps/${APPLIANCE_UNIT}

    mv ${GITHUB_REPOSITORY_FOLDER}/${APPLIANCE_UNIT}.war ${CATALINA_HOME}/${APPLIANCE_UNIT}/webapps/${APPLIANCE_UNIT}
    (cd ${CATALINA_HOME}/${APPLIANCE_UNIT}/webapps/${APPLIANCE_UNIT}; jar xf ${APPLIANCE_UNIT}.war)

    rm ${CATALINA_HOME}/${APPLIANCE_UNIT}/webapps/${APPLIANCE_UNIT}/${APPLIANCE_UNIT}.war

    # Do not allow external accesses in engine and etl appliances
    if [ "${APPLIANCE_UNIT}" = "engine" ] || [ "${APPLIANCE_UNIT}" = "etl" ] ; then

	    echo "Applying access restriction from external networks..."
	    # Find a way to change allowed addresses with the internal network address
	    # xmlstarlet ed -L -s '/Context' -t elem -n 'Valve' \
	    #		  -i '/Context/Valve' -t attr -n 'className' -v 'org.apache.catalina.valves.RemoteAddrValve' \
	    #                 -i '/Context/Valve' -t attr -n 'allow' -v '172\.17\.\d+\.\d+' \
	    #                 ${CATALINA_HOME}/${APPLIANCE_UNIT}/conf/context.xml
    fi

    if [ "${APPLIANCE_UNIT}" = "retrieval" ]; then
            git clone https://github.com/gciotto/archiver-viewer.git ${CATALINA_HOME}/${APPLIANCE_UNIT}/webapps/${APPLIANCE_UNIT}/ui/archiver-viewer
            git clone https://github.com/slacmshankar/svg_viewer.git ${CATALINA_HOME}/${APPLIANCE_UNIT}/webapps/${APPLIANCE_UNIT}/ui/viewer
    fi

    RAND_SRV_PORT=$((RAND_SRV_PORT+1))

    TOMCAT_USERS=${CATALINA_HOME}/${APPLIANCE_UNIT}/conf/tomcat-users.xml
    sed -i -e "43a<user username=\"${TOMCAT_USERNAME}\" password=\"${TOMCAT_PASSWORD}\" roles=\"manager-gui\"/>" ${TOMCAT_USERS} 
    sed -i -e "43a<role rolename=\"manager-gui\"/>" ${TOMCAT_USERS}
done

TOMCAT_USERS=${CATALINA_HOME}/conf/tomcat-users.xml
sed -i -e "43a<user username=\"${TOMCAT_USERNAME}\" password=\"${TOMCAT_PASSWORD}\" roles=\"manager-gui\"/>" ${TOMCAT_USERS} 
sed -i -e "43a<role rolename=\"manager-gui\"/>" ${TOMCAT_USERS}

