#!/bin/bash
source /scripts/activemq.env

# Change cluster inet address
sed -i "s/10\.128\.2\.3/${IP_ADDRESS}/" /etc/activemq/instances-enabled/main/activemq.xml

# A simple script to start activemq service
/etc/init.d/activemq start

# Does not allow Docker container to finish and close
tail -f /dev/null
