#!/bin/bash
source envs.sh
source zenity.sh

function cleanup {      
        if [ -d extracted_files ]; then
                rm -rfd extracted_files
        fi
        if [ -d resources ]; then
                rm -rfd resources
        fi
}
trap cleanup EXIT

cleanup

mkdir -p resources
pushd resources
wget ${TOMCAT_URL}
tar -zxf ${TOMCAT_DISTRIBUTION}.tar.gz
export TOMCAT_HOME=$(pwd)/${TOMCAT_DISTRIBUTION} 
wget https://dev.mysql.com/get/Downloads/Connector-J/${MYSQL_CONNECTOR}.tar.gz --no-check-certificate
tar -xvf ${MYSQL_CONNECTOR}.tar.gz
mv ${MYSQL_CONNECTOR}/${MYSQL_CONNECTOR}-bin.jar .
popd 

MSG="Wish to clone and build epicsappliances repo?"
echo ${MSG}
zenity --text="${MSG}" --question --width=$W --height=150
if [[ $? == 0 ]] ; then
        pushd resources
        git clone ${ARCHIVER_REPO}
        cd epicsarchiverap
        ant
        popd
fi

MSG=$(pwd)/resources
MSG="Where is the epicsappliances build file (tar.gz)? Should be on the folder ${MSG}"
echo $MSG
ARCH_TAR=$(zenity  --title "$MSG" --file-selection --width=$W --height=150)
if [[ ! -f ${ARCH_TAR} ]]
then
        MSG="${ARCH_TAR} does not seem to be a valid file"
        echo ${MSG}
        zenity --text="${MSG}" --error --width=$W --height=150
        exit 1
fi

mkdir extracted_files
tar -C extracted_files -zxf  ${ARCH_TAR}
rm -rvfd extracted_files/install_scripts
mkdir -p extracted_files/install_scripts

cp -rf install_scripts/ extracted_files/
export SCRIPTS_DIR=$(pwd)/extracted_files/install_scripts
echo Scripts dir $SCRIPTS_DIR
ls
pushd ${SCRIPTS_DIR}
ls 
. ./single_machine_install.sh
popd  

mv resources/${MYSQL_CONNECTOR}-bin.jar ${DEPLOY_DIR}

STARTUP_SH=${DEPLOY_DIR}/sampleStartup.sh

sed -i -e "14cexport JAVA_OPTS=\"${JAVA_OPTS}\"" ${STARTUP_SH}

sed -i -e "30cexport ARCHAPPL_SHORT_TERM_FOLDER=${ARCHAPPL_SHORT_TERM_FOLDER}" ${STARTUP_SH}
sed -i -e "31cexport ARCHAPPL_MEDIUM_TERM_FOLDER=${ARCHAPPL_MEDIUM_TERM_FOLDER}" ${STARTUP_SH}
sed -i -e "32cexport ARCHAPPL_LONG_TERM_FOLDER=${ARCHAPPL_LONG_TERM_FOLDER}" ${STARTUP_SH}

rm -rvfd extracted_files

for APPLIANCE_UNIT in "engine" "retrieval" "etl" "mgmt"
do
	# TOMCAT_USERS=${DEPLOY_DIR}/${APPLIANCE_UNIT}/conf/tomcat-users.xml
	# sed -i -e "43a<user username=\"${TOMCAT_USERNAME}\" password=\"${TOMCAT_PASSWORD}\" roles=\"manager-gui\"/>" ${TOMCAT_USERS}
	# sed -i -e "43a<role rolename=\"manager-gui\"/>" ${TOMCAT_USERS} 
        if [ $APPLIANCE_UNIT == "mgmt" ]; then
                for file in "appliance.html" "cacompare.html" "index.html" "integration.html" "metrics.html" "pvdetails.html" "redirect.html" "reports.html" "storage.html"
                do
                        sed -i "s/LCLS/LNLS/g" ${UI_DIR}/${file}
                        echo ${UI_DIR}/${file}
                done
                sed -i "s/Jingchen Zhou/LNLS CON group/g" ${UI_DIR}/index.html
                sed -i "s/Murali Shankar at 650 xxx xxxx or Bob Hall at 650 xxx xxxx/LNLS CON group/g" ${UI_DIR}/index.html

                cp -f labLogo.png ${IMG_DIR}
                cp -f labLogo2.png ${IMG_DIR}
        fi
        if [ $APPLIANCE_UNIT == "retrieval" ]; then
                pushd ${DEPLOY_DIR}/${APPLIANCE_UNIT}/webapps/retrieval/ui
                rm -rvfd viewer
                git clone ${ARCHIVER_VIEWER_REPO}
                mv archiver-viewer viewer
                mv viewer/index.html viewer/archViewer.html
                pushd viewer/js
                sed -i "s/10\.0\.4\.57\:11998/10\.0\.6\.51\:17668/g" archiver-viewer.min.js
                sed -i "s/10\.0\.6\.57\:11998/10\.0\.6\.51\:17668/g" archiver-viewer.min.js
                sed -i "s/10\.0\.4\.57\:11998/10\.0\.6\.51\:17668/g" archiver-viewer.js
                sed -i "s/10\.0\.6\.57\:11998/10\.0\.6\.51\:17668/g" archiver-viewer.js
                popd
                popd
        fi
done
