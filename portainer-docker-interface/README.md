# Portainer

</href>https://github.com/portainer/portainer</href>

## Create a folder to persist the Portainer data and modify the access permissions.
```
sudo mkdir /etc/portainer_data
```

## Deploying Portainer is as simple as:
``` 
$ docker run -d -p 9000:9000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock -v /etc/portainer_data:/data portainer/portainer
```

## Secure Portainer using SSL

As we are running NGINX on the same host as portainer, we can use ssl on the proxy side. Still one can configured ssl directly on the docker image:

To do so, you can use the following flags --ssl, --sslcert and --sslkey:
```
$ docker run -d -p 443:9000 --name portainer --restart always -v ~/local-certs:/certs -v /etc/portainer_data:/data portainer/portainer --ssl --sslcert /etc/ssl/portainer.crt --sslkey /etc/ssl/portainer.key
```

## Security
Assuming `iptables` is being used as firewall, two simple rules are recommended to be added:<br>
```
iptables -I INPUT 2 -p tcp --dport 9000 ! -s 127.0.0.1 -j REJECT
```
Will only accept inputs from `127.0.0.1` so external connections must go through a proxy server (nginx). `--dport` is to be set according to the portainer port (9000 is the default configuration for portainer).
```
iptables -I OUTPUT 2\
  -m owner ! --uid-owner  root \
  -m owner ! --uid-owner controle \
  -m owner ! --uid-owner www-data \
  -p tcp --dport 9000  -j REJECT
```
Will block unauthorized users access.<br>

`--uid-owner` according to the server account name:<br><br>
The package iptables-persistent on Ubuntu and Debian facilitates to reapply firewall rules at boot time.<br>
`apt-get install iptables-persistent`<br>
To view the configured rules:<br>
`iptables -L`

To persist the iptables rules after reboot, run dpkg-reconfigure and respond Yes when prompted.<br>
`dpkg-reconfigure iptables-persistent`

## Reverse Proxy

NGINX is already configured to support Portainer at port 9000.
