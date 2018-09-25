#!/bin/bash

cd /opt/epics-R3.15.5/modules
wget https://github.com/epics-extensions/ca-gateway/archive/R2-1-0-0.tar.gz
tar -xvzf R2-1-0-0.tar.gz
rm R2-1-0-0.tar.gz
echo 'EPICS_BASE=/opt/epics-R3.15.5/base' > ca-gateway-R2-1-0-0/configure/RELEASE.local
cd ca-gateway-R2-1-0-0
make