CROWD_VERSION=4.4.1
CROWD_FILE=atlassian-crowd-$(CROWD_VERSION).tar.gz
CROWD_SRCURL=https://product-downloads.atlassian.com/software/crowd/downloads/$(CROWD_FILE)

VOLUMES=-v $(shell pwd)/debug:/usr/local/debug -v /usr/local/crowd:/var/atlassian/crowd

.PHONY: help
help: setup
	@echo "Run 'make build' to create the patched Crowd"
	@echo "Run 'make start' to start it. If you are prompted for a licence,"
	@echo "use your existing licence."
	@echo ""
	@echo "  ** Note that you MUST HAVE AN EXISTING LICENCE! **"
	@echo ""

.PHONY: setup
setup: /usr/local/crowd

/usr/local/crowd:
	mkdir $@
	chmod 777 $@

.PHONY: start
start: .docker_build
	@[ "$(shell docker ps -q -f name=crowd)" ] && echo "Crowd already running" || docker run -d $(VOLUMES) --publish=8095:8095 --name crowd crowd:$(CROWD_VERSION)

.PHONY: stop
stop:
	docker rm -f crowd || :

.PHONY: build
build: .docker_build

.docker_build: setup $(wildcard docker/*)
	docker build --tag crowd:$(CROWD_VERSION) --build-arg CROWD_VERSION=$(CROWD_VERSION) --build-arg CROWD_FILE=$(CROWD_FILE) --build-arg CROWD_SRCURL=$(CROWD_SRCURL) docker/
	touch $@

.PHONY: shell
shell: start
	docker exec -it --user=0 crowd /bin/bash

debug: stop .docker_build
	docker run -it --rm $(VOLUMES) --publish=8095:8095 --name crowd-debug crowd:$(CROWD_VERSION) /bin/bash

