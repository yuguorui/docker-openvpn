VERSION ?= latest

.PHONY: init gen_config start stop reset clean
NETWORK_ID?=192.168.1.0
MASK?=255.255.255.0
# i.e: the game's under 192.168.1.*, then
# NETWORK_ID is 192.168.1.0, MASK is 255.255.255.0

TUN_INTERFACE?=tun0
WAN_INTERFACE?=en0

init:
	# docker pull alpine:latest
	docker-compose build
	docker-compose run --rm vpn /bin/bash -c " \
		ovpn_genconfig -u udp://$(HOST):$(PORT) && \
		ovpn_initpki nopass && \
		ovpn_addiroute $(NETWORK_ID) $(MASK)"

gen_config:
	docker-compose run --rm vpn /bin/bash -c " \
		easyrsa build-client-full router nopass && \
		easyrsa build-client-full player nopass "
	docker-compose run --rm vpn ovpn_getclient router > router.ovpn
	docker-compose run --rm vpn ovpn_getclient player > player.ovpn

start:
	docker-compose up -d vpn

stop:
	docker-compose down

reset:
	docker-compose run --rm vpn /bin/bash -c " \
		ovpn_cleariroute && \
		ovpn_addiroute $(NETWORK_ID) $(MASK)"
	docker-compose down
	# needs manual restart

clean:
	docker-compose down
	rm -rf ./vpn_data
