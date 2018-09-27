# EPICS Archiver Appliances
Based on the installation script provided by <href>https://github.com/slacmshankar/epicsarchiverap</href>.<br>
Make sure to have an `envs.env` file at `/opt`. View the example file on this project for a refference implementation.<br>
It's needed to have MySql running with the user and database already created.

## Security Measures
Usually only one instance of the Archiver Appliance will run. Assuming that is the case, for security reasons
one should block the acces of the mgmt container (tomcat container) allowing only trusted IPs.<br>

For a simple setup where a reverse proxy server is running on the same machine as the appliance, a simple solution if to set the archiver ip to 
`127.0.0.1`, restrict the acces to the mgmt port, in this particular example `17665`, and reverse proxy to `127.0.0.1` with a secure connection, preferably using some sort of authentication:<br>
`iptables -I INPUT 1 -p tcp --dport 17665 ! -s 127.0.0.1 -j REJEC`

The package iptables-persistent on Ubuntu and Debian facilitates to reapply firewall rules at boot time.<br>
`apt-get install iptables-persistent`
To view the configured rules:
`iptables -L`

To persist the iptables rules after reboot, run dpkg-reconfigure and respond Yes when prompted.<br>
`dpkg-reconfigure iptables-persistent`



