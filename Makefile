# GITHUB_USER containing '@' char must be escaped with '%40'
GITHUB_USER := $(shell echo $(GITHUB_USER) | sed 's/@/%40/g')

.PHONY: default
default:: init;

.PHONY: init\:
init::
ifndef DOCKER_USER
	$(info DOCKER_USER not defined)
	exit -1
endif
ifndef DOCKER_PASS
	$(info DOCKER_PASS not defined)
	exit -1
endif
ifndef GITHUB_TOKEN
	$(info GITHUB_TOKEN not defined)
	exit -1
endif

-include $(shell curl -H 'Authorization: token ${GITHUB_TOKEN}' -H 'Accept: application/vnd.github.v4.raw' -L https://api.github.com/repos/open-cluster-management/build-harness-extensions/contents/templates/Makefile.build-harness-bootstrap -o .build-harness-bootstrap; echo .build-harness-bootstrap)

REGISTRY ?= quay.io/rhibmcollab
IMG ?= multiclusterhub-repo
VERSION ?= latest

image:
	./cicd-scripts/build.sh "$(REGISTRY)/$(IMG):$(VERSION)"

push:
	./scripts/push.sh "$(REGISTRY)/$(IMG):$(VERSION)"

unit-test:
	./cicd-scripts/unit-test.sh

# local builds a docker image and runs it locally
local:
	docker build -t "$(IMG):$(VERSION)" . && docker run -it --rm --expose 3000 -p 3000:3000  "$(IMG):$(VERSION)"
	