PREFIX ?= /usr/local

.PHONY: install uninstall install-ssl-cert

install:
	sudo cp -r main-page /opt/
	sudo cp -r archiver-viewer /opt/
	sudo apt-get install nginx
	sudo rm -f /etc/nginx/sites-enabled/default
	sudo cp archiver-conf /etc/nginx/sites-enabled/archiver-conf
	sudo cp -r main-page /opt
	sudo nginx -t
	sudo systemctl restart nginx.service

uninstall:

install-ssl-cert:
	sudo mkdir -p /etc/ssl/certs
	sudo openssl \
	req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout /etc/ssl/arch-viewer.key \
	-out /etc/ssl/arch-viewer.crt
