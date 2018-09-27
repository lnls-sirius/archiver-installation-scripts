# NGINX Reverse Proxy and LDAP Authentication

The current configuration supports htpasswd authentication and assumes that NGINX is running on the same machine as the appliances.

## Using OpenSSL to Generate Self-Signed Certificates
OpenSSL is also packaged for most Linux distributions, installing it should be as simple as:<br>
`sudo apt-get install openssl`<br>
Directory where the certificates will be placed.<br>
`sudo mkdir -p /etc/ssl/certs`<br>

Make the certificates<br>
`sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/openhab.key -out /etc/ssl/openhab.crt`<br>

## Simple authentication ... Quick and dirty LDAP replacement
Creating the First User<br>
Using htpasswd to generate a username/password file, this utility can be found in the apache2-utils package:<br>
`sudo apt-get install apache2-utils`<br>

To generate a file that NGINX can use you use the following command, don’t forget to change username to something meaningful!<br>
`sudo htpasswd -c /etc/nginx/.htpasswd username`<br>

To add a new user:<br>
`sudo htpasswd /etc/nginx/.htpasswd username`<br>

and to delete an existing user:<br>
`sudo htpasswd -D /etc/nginx/.htpasswd username`<br>
