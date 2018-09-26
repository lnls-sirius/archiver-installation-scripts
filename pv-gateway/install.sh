#!/bin/bash
source /opt/envs.env

cd ${EPICS_MODULES}
wget https://github.com/epics-extensions/ca-gateway/archive/R2-1-0-0.tar.gz --no-check-certificate
tar -xvzf R2-1-0-0.tar.gz
rm R2-1-0-0.tar.gz
echo "EPICS_BASE=${EPICS_BASE}" > ca-gateway-R2-1-0-0/configure/RELEASE.local
cd ca-gateway-R2-1-0-0
make
