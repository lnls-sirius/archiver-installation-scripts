#!/bin/bash
if [ ! -d /opt/wait-for-it ]; then
    pushd /opt
    git clone https://github.com/vishnubob/wait-for-it.git
    popd
fi

