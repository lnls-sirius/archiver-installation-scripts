#!/bin/bash
# EPICS environment variables
export EPICS_BASE_VERSION=3.15.5
export EPICS_BASE_NAME=epics-${EPICS_BASE_VERSION} 

export EPICS_HOST_ARCH=linux-x86_64 
export EPICS_BASE=/opt/epics-R3.15.5/base
export PATH=${EPICS_BASE}/bin/${EPICS_HOST_ARCH}:$PATH
 