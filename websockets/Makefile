NWAKU_CONTAINER=nwaku-simulator_nwaku_1
IMAGE=quay.io/vpavlin0/waku-websockets:latest
ENV_FILE=.env.example

get_ma = $(shell docker logs $(1) | grep "Listening on" | sed 's#.*full=.*\[\(.*wss.*\)\]#\1#')

build:
	docker build -t $(IMAGE) .

get-ma:
	echo $(call get_ma,$(NWAKU_CONTAINER))

update-ma: MA := $(call get_ma,$(NWAKU_CONTAINER))
update-ma:
	echo $(MA)
	sed -i.bckp 's#MULTIADDRESS=.*#MULTIADDRESS=$(MA)#'	$(ENV_FILE)

run: update-ma
	docker-compose up -d -t 0 --force-recreate

stop:
	docker-compose down -t 0