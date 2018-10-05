# EPICS Archiver Appliances
Based on the installation script provided by <href>https://github.com/slacmshankar/epicsarchiverap</href>.<br>
Make sure to have an `envs.env` file at `/opt`. View the example file on this project for a refference implementation.<br>
It's needed to have MySql running with the user and database already created.

The EPICS Appliance consists of 4 Java applications, each running in a separated Tomcat instance.

## MySQL Setup
```
CREATE DATABASE 'database_name';
USE 'database_name';
CREATE USER 'user';
GRANT ALL PRIVILEGES ON 'database_name'.* To 'user' IDENTIFIED BY 'password';
```
Now copy and paste :
```
CREATE TABLE PVTypeInfo ( 
	pvName VARCHAR(255) NOT NULL PRIMARY KEY,
	typeInfoJSON MEDIUMTEXT NOT NULL,
	last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE PVAliases ( 
	pvName VARCHAR(255) NOT NULL PRIMARY KEY,
	realName VARCHAR(256) NOT NULL,
	last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE ArchivePVRequests ( 
	pvName VARCHAR(255) NOT NULL PRIMARY KEY,
	userParams MEDIUMTEXT NOT NULL,
	last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE ExternalDataServers ( 
	serverid VARCHAR(255) NOT NULL PRIMARY KEY,
	serverinfo MEDIUMTEXT NOT NULL,
	last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
```

To load an appliance dump:<br>
<b>Beware that the current data could be erased. Always check the sql you're runnig !</b>
```
mysql -u 'user' -p 'database_name' < 'dump.sql'
```


## Installing

Before installing the archiver service, the user might want to change some variables at `envs.env`, for example :
```
...
export APPLIANCE_ADDRESS="127.0.0.1"
export ARCHAPPL_MYIDENTITY="lnls_control_appliance_1"
export APPLIANCES_NAME="lnls_appliances.xml"
export POLICIES_NAME="lnls_policies.py"
...
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
...
export JAVA_OPTS=-XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap # Use when inside a docker container
...
APPLIANCE_STORAGE_FOLDER=/epics-archiver/storage 
...
```


After configuring all the necessary items, run:
```
./install.sh
```
A temporary folder called <b>resources</b> will be created inside this folder during the installation process.<br>
All downloaded files will go there.Pay attention on the messages that will prompt and select the corresponding files.<br>
<i>A fully automated installation is under development alogside it's container counterpart</i>.

It's recommended to download the compiled archiver vesion.


## Storage
Short term storage should be a ram disk for optmal performance. One should use tempfs and specify the size limit according to the system setup.
/storage/epics-archiver/sts/ as an example: 

Edit the file `/etc/fstab` in order do mount the partitions on boot. Remember to backup the original file in case something goes wrong.
As an example here is a second hardrive and a tmpfs used on a testing appliance. Use `ls -l /dev/disk/by-uuid` to find out the UUID.

```
UUID=31b4619a-5e8a-4874-9f68-1d20ae163481  /storage/epics-archiver/                ext4     errors=remount-ro        0       1
none                                       /storage/epics-archiver/sts/            tmpfs    defaults, size=20480     0       0
```

For testing purposes one can simply do: <br>
```
mkdir /storage/epics-archiver/sts/
mount -t tmpfs -o size=2048m tmpfs /storage/epics-archiver/sts/
```
Usually for medium and long term storage multiple drivers will be used. The appliance must see all disks as a single directory in order to function.
A simple RAID setup is enought to work. There are multiple ways of setting up a RAID config, all depends on current needs and hardware available.

For a Supermicro machine, enter the bios, set the SATA mode to RAID and reboot.
Press Ctrl+c to enter the RAID manangment utility at boot time.
Create a new RAID volume if needed and add the necessary disks to the volume.
In the current setup, we are running the operating system outside the RAID array in a SSD drive, so we keep it out of the RAID array.

If everything goest

## Security Measures
Usually only one instance of the Archiver Appliance will run. Assuming that is the case, for security reasons
one should block the acces of the mgmt container (tomcat container) allowing only trusted IPs.<br>

For a simple setup where a reverse proxy server is running on the same machine as the appliance, a simple solution is to set the archiver ip to 
`127.0.0.1` on the appliances.xml file ( `<mgmt_url>http://127.0.0.1:17665/mgmt/bpl</mgmt_url>` ), restrict the acces to the mgmt port, in this particular example `17665`, and reverse proxy to `127.0.0.1` with a secure connection, preferably using some sort of authentication(Remember to change `! --uid-owner controle` according to the server account name):<br>

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
 