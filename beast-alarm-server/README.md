# BEAST Alarm Server
Simplified installation guide.

## BEAST Alarm Server Application
Based on <href>https://github.com/lnls-sirius/docker-alarm-server.git</href>.<br>
Remember to set the correct values at `LNLS-CON.ini`.<br>
Modify the hostnames according to your setup.

```
...
org.csstudio.alarm.beast/rdb_url=jdbc:postgresql://alarm-server-postgres-db:5432/lnls_alarms
...
org.csstudio.alarm.beast/jms_url=failover:(tcp://alarm-server-activemq:61616)
...
org.csstudio.platform.libs.epics/addr_list=10.0.6.49
...
```
Run to build and install:
``` 
sudo ./install-beast.sh
``` 

To setup the sevices (Apache ActiveMQ and Postgresql are required.):
``` 
sudo make install-beast
sudo systemctl status beast-notifier
``` 

## Server notifier
Based on <href>https://github.com/lnls-sirius/docker-alarm-server.git</href>.<br>
Remember to set the correct values at `beast-alarm-server/LNLS-CON.ini` (the same config as the BEAST installation). 

Run the script:
```
sudo install-notifier.sh
``` 
then to configure the services:
```
sudo make install-alarm-notifier
sudo systemctl status alarm-notifier
```

## Apache ActiveMQ
Based on <href>https://github.com/lnls-sirius/docker-alarm-activemq.git</href><br>

Apache ActiveMQ ™ is the most popular and powerful open source messaging and Integration Patterns server.<br>
Apache ActiveMQ is fast, supports many Cross Language Clients and Protocols, comes with easy to use Enterprise Integration Patterns and many advanced features while fully supporting JMS 1.1 and J2EE 1.4.<br>
Apache ActiveMQ is released under the Apache 2.0 License<br>

Run the script:
```
sudo install-activemq.sh
``` 
The service shoud be created automatically:
```
sudo systemctl status activemq.service
```

One should use systemctl to manage this service.
```
sudo systemctl status activemq.service
sudo systemctl start activemq.service
sudo systemctl stop activemq.service
sudo systemctl enable activemq.service
```

## Database configuration
Based on <href>https://github.com/lnls-sirius/docker-alarm-postgres-db</href>.<br>

sudo su - postgres
psql

`make install-postgree`
Check <href>https://www.postgresql.org/docs/10/static/server-start.html</href><br>

Create the database and users. As an example we are using:
```
POSTGRES_USER=lnls_alarm_user
POSTGRES_PASSWORD=controle
POSTGRES_DB=lnls_alarms
POSTGRES_PORT=5432
PGDATA=/var/lib/postgresql/data/alarm-db

NETWORK_ID=127.0.0.1
```

Change the user to postgres :
```
su - postgres
```
Create User for Postgres
```
$ createuser ${POSTGRES_USER}
```
Create Database
```
$ createdb ${POSTGRES_DB}
```


Acces the postgres Shell
```
psql ( enter the password for postgressql)
```
Provide the privileges to the postgres user
```
$ ALTER USER lnls_alarm_user WITH ENCRYPTED PASSWORD 'controle';
$ ALTER USER lnls_alarm_user WITH SUPERUSER;
```

Load  ALARM_POSTGRES.sql
```
psql -a -d lnls_alarms -f docker-alarm-postgres-db/sql/ALARM_POSTGRES.sql
```

In order to start PostgreSQL on boot:
```
sudo update-rc.d postgresql enable
```

It's possible to alter the data location by changing the value of `data_directory` at via: 
```
sudo nano /etc/postgresql/10/main/postgresql.conf
```
By default it's set to `data_directory = '/var/lib/postgresql/10/main'`.
