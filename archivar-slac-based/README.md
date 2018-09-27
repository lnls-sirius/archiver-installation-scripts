# EPICS Archiver Appliances
Based on the installation script provided by <href>https://github.com/slacmshankar/epicsarchiverap</href>.<br>
Make sure to have an `envs.env` file at `/opt`. View the example file on this project for a refference implementation.<br>
It's needed to have MySql running with the user and database already created.

## Security Measures
Usually only one instance of the Archiver Appliance will run. Assuming that is the case, for security reasons
one should block the acces of the mgmt container (tomcat container) allowing only trusted IPs.<br>

For a simple setup where a reverse proxy server is running on the same machine as the appliance, a simple solution is to set the archiver ip to 
`127.0.0.1` on the appliances.xml file ( `<mgmt_url>http://127.0.0.1:17665/mgmt/bpl</mgmt_url>` ), restrict the acces to the mgmt port, in this particular example `17665`, and reverse proxy to `127.0.0.1` with a secure connection, preferably using some sort of authentication:<br>
```
iptables -I INPUT 1 -p tcp --dport 17665 ! -s 127.0.0.1 -j REJECT
iptables -I OUTPUT 1  -m owner ! --uid-owner root -m owner ! --uid-owner controle -m owner ! --uid-owner www-data -p tcp --dport 17665  -j REJECT
```
The package iptables-persistent on Ubuntu and Debian facilitates to reapply firewall rules at boot time.<br>
`apt-get install iptables-persistent`<br>
To view the configured rules:<br>
`iptables -L`

To persist the iptables rules after reboot, run dpkg-reconfigure and respond Yes when prompted.<br>
`dpkg-reconfigure iptables-persistent`

<!-- ### Iptables logging
```
iptables -N LOGGING
iptables -A INPUT -j LOGGING
iptables -A OUTPUT -j LOGGING
iptables -A LOGGING -m limit --limit 2/min -j LOG --log-prefix "IPTables-Dropped: " --log-level 4
iptables -A LOGGING -j DROP
```
<ul>
<li>`iptables -N LOGGING`: Create a new chain called LOGGING.</li>
<li>`iptables -A INPUT -j LOGGING`: All the remaining incoming packets will jump to the LOGGING chain.</li>
<li>line#3: Log the incoming packets to syslog (/var/log/messages).</li>
<li>`iptables -A LOGGING -j DROP`: Finally, drop all the packets that came to the LOGGING chain. i.e now it really drops the incoming packets.</li>
<ul>
  -->