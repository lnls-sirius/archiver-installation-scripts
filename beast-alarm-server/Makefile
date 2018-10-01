PREFIX ?= /usr/local

SERVICE_NAME_BEAST = beast
SRC_SERVICE_FILE_BEAST = ${SERVICE_NAME_BEAST}.service

SERVICE_NAME_NOTIFIER = alarm-notifier
SRC_SERVICE_FILE_NOTIFIER = ${SERVICE_NAME_NOTIFIER}.service

SERVICE_FILE_DEST = /etc/systemd/system

.PHONY: install-beast install-alarm-notifier

install-beast:
	mkdir -p /scripts
	cp run-beast.sh /scripts/run-beast.sh
	cp -f --preserve=mode ${SRC_SERVICE_FILE_BEAST} ${SERVICE_FILE_DEST}
	systemctl daemon-reload
	systemctl stop ${SERVICE_NAME_BEAST}
	systemctl start ${SERVICE_NAME_BEAST}
	systemctl enable ${SERVICE_NAME_BEAST}

uninstall-beast:
	systemctl stop ${SERVICE_NAME_BEAST}
	rm -f ${SERVICE_FILE_DEST}/${SRC_SERVICE_FILE_BEAST}
	rm -f -R ${DOCKER_FILES_DEST}
	systemctl daemon-reload

install-alarm-notifier:
	mkdir -p /scripts
	cp run-beast.sh /scripts/run-alarm-notifier.sh
	cp -f --preserve=mode ${SRC_SERVICE_FILE_NOTIFIER} ${SERVICE_FILE_DEST}
	systemctl daemon-reload
	systemctl stop ${SERVICE_NAME_NOTIFIER}
	systemctl start ${SERVICE_NAME_NOTIFIER}
	systemctl enable ${SERVICE_NAME_NOTIFIER}


uninstall-alarm-notifier:
	systemctl stop ${SERVICE_NAME_NOTIFIER}
	rm -f ${SERVICE_FILE_DEST}/${SRC_SERVICE_FILE_NOTIFIER}
	rm -f -R ${DOCKER_FILES_DEST}
	systemctl daemon-reload
