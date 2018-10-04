#!/bin/bash

if [ -d /opt/wait-for-it ]; then
    pushd /opt/wait-for-it
    ./wait-for-it.sh -t 0 -h localhost -p 3306 -- echo "MySQL Server is UP! 3306."
    popd
fi

./sampleStartup.sh start
