NAME="example"
PUBLIC_PORT=3000
PORT=${PUBLIC_PORT}
IMAGE_NAME = "grengojbo/${NAME}"
SITE="site.uatv.me"
NEW_RELIC_LICENSE_KEY=<your key>
APP_RAM=64M

.PHONY: all run clean push create shell build destroy release

all: push

push:
	git push deis master

clean:
	docker rmi ${IMAGE_NAME}

create:
	deis create ${NAME}
	deis domains:add ${SITE} -a ${NAME}
	deis domains:add www.${SITE} -a ${NAME}
	deis limits:set -m cmd=${APP_RAM} -a ${NAME}
	deis tags:set cluster=yes -a ${NAME}
	deis config:set NAME_APP=${NAME} -a ${NAME}
	deis config:set NODE_ENV=production
	# deis config:set NEW_RELIC_LICENSE_KEY=${NEW_RELIC_LICENSE_KEY} -a ${NAME}
	# deis config:set NEW_RELIC_APP_NAME=${NAME} -a ${NAME}
	# deis config:set NEW_RELIC_APDEX=0.5
	# deis config:set NEW_RELIC_CONFIG_FILE=/app/newrelic.js -a ${NAME}
	# deis config:set NEW_RELIC_BROWSER_MONITOR_ENABLE=true -a ${NAME}

run:
	npm run debug

shell:
	docker run --rm -v /storage/${NAME}:/storage/${NAME} --name ${NAME} -e NAME_APP=${NAME} -i -t -p ${PUBLIC_PORT}:{PORT} ${IMAGE_NAME} /bin/bash

build:
	@docker build -t ${IMAGE_NAME} .

install:
	# docker push grengojbo/sil 10.0.7.235:5000/sil
	fleetctl submit ${NAME}.service
	fleetctl submit ${NAME}-log.service

destroy:
	deis apps:destroy --app=${NAME} --confirm=${NAME}

release:
	@gulp dist:release
