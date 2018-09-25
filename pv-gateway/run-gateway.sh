#!/bin/bash
source /opt/envs.evs

CIP="10.0.6.48"

pushd ${EPICS_MODULES}/modules/ca-gateway-R2-1-0-0/bin/${EPICS_HOST_ARCH}
./gateway -archive -no_cache -log gateway.log -cip ${CIP}
popd