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

As we are running NGINX on the same host as portainer, we can use ssl on the proxy side. Still one can configured ssl directly at:

By default, Portainer’s web interface and API is exposed over HTTP. This is not secured, it’s recommended to enable SSL in a production environment.

To do so, you can use the following flags --ssl, --sslcert and --sslkey:
```
$ docker run -d -p 443:9000 --name portainer --restart always -v ~/local-certs:/certs -v /etc/portainer_data:/data portainer/portainer --ssl --sslcert /etc/ssl/portainer.crt --sslkey /etc/ssl/portainer.key
```

## Security

`! --uid-owner controle` according to the server account name):<br>

```
iptables -I INPUT 2 -p tcp --dport 9000 ! -s 127.0.0.1 -j REJECT
iptables -I OUTPUT 2\
  -m owner ! --uid-owner  root \
  -m owner ! --uid-owner controle \
  -m owner ! --uid-owner www-data \
  -p tcp --dport 9000  -j REJECT
```

The package iptables-persistent on Ubuntu and Debian facilitates to reapply firewall rules at boot time.<br>
`apt-get install iptables-persistent`<br>
To view the configured rules:<br>
`iptables -L`

To persist the iptables rules after reboot, run dpkg-reconfigure and respond Yes when prompted.<br>
`dpkg-reconfigure iptables-persistent`

## Reverse Proxy

NGINX is already configured to support Portainer at port 9000.