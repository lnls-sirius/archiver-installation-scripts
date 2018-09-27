#!/bin/bash
# Extra dependencies 
wget ${TOMCAT_NATIVE_URL} -P ${CATALINA_HOME} --no-check-certificate
tar -C ${CATALINA_HOME} -zxf ${CATALINA_HOME}/${TOMCAT_NATIVE_DISTRIBUTION}.tar.gz
rm ${CATALINA_HOME}/${TOMCAT_NATIVE_DISTRIBUTION}.tar.gz

wget ${APR_URL} -P ${CATALINA_HOME} --no-check-certificate
tar -C ${CATALINA_HOME} -zxf ${CATALINA_HOME}/${APR_DISTRIBUTION}.tar.gz
rm ${CATALINA_HOME}/${APR_DISTRIBUTION}.tar.gz

wget ${OPENSSL_URL} -P ${CATALINA_HOME} --no-check-certificate
tar -C ${CATALINA_HOME} -zxf ${CATALINA_HOME}/${OPENSSL_DISTRIBUTION}.tar.gz
rm ${CATALINA_HOME}/${OPENSSL_DISTRIBUTION}.tar.gz

# OpenSSL
pushd ${CATALINA_HOME}/${OPENSSL_DISTRIBUTION}
pwd
sleep 1
./config
make -j32
make test
make install
popd
pwd
sleep 1

# APR Install 
mkdir -p ${APR_DIR}
pushd ${CATALINA_HOME}/${APR_DISTRIBUTION}
pwd
sleep 1
CC="gcc -m64" ./configure --prefix=${APR_DIR}
make -j32
# make test
make install
# cd test
# ./testall -v
popd
pwd
sleep 1

# Tomcat Native
pushd ${CATALINA_HOME}/${TOMCAT_NATIVE_DISTRIBUTION}/native
pwd
ls
sleep 1
./configure --with-apr=${APR_DIR} --with-java-home=${JAVA_HOME} --with-ssl=${OPENSSL_DIR} --prefix=${CATALINA_HOME}

make && make install
popd
pwd
ls
sleep 1