PREFIX ?= /usr/local

SERVICE_NAME = pv-gateway
SRC_SERVICE_FILE = ${SERVICE_NAME}.service
SERVICE_FILE_DEST = /etc/systemd/system
SCRIPS_DIR=/scripts

.PHONY: install uninstall
install:
	mkdir -p ${SCRIPS_DIR}
	cp run-gateway.sh ${SCRIPS_DIR}/run-gateway.sh
	cp --preserve=mode ${SRC_SERVICE_FILE} ${SERVICE_FILE_DEST}
	systemctl daemon-reload
	systemctl stop ${SERVICE_NAME}
	systemctl start ${SERVICE_NAME}
	systemctl enable ${SERVICE_NAME}

uninstall:
	systemctl stop ${SERVICE_NAME}
	rm -f ${SERVICE_FILE_DEST}/${SRC_SERVICE_FILE}
	rm -f -R ${DOCKER_FILES_DEST}
	systemctl daemon-reload

