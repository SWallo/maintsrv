GO_BIN := $(shell which go)
DOCKER_BIN := $(shell which docker)
GO_LINT := $(shell which golint)
IMAGE_PATH := ghcr.io/swallo/maintsrv
PROJECT_NAME := maintsrv
PKG := swallo/maintsrv
PKG_LIST := $(shell go list ${PKG}/...)

.PHONY: all dep build build-all clean test race lint release

ARCHS := amd64 arm64

all: release

lint: ## Lint the files
	${GO_LINT} ${PKG_LIST}

test: ## Run unittests
	${GO_BIN} test -short ${PKG_LIST}

race: ## Run race tests
	${GO_BIN} test -race -short ${PKG_LIST}

dep: ## Get the dependencies
	${GO_BIN} get -v
	${GO_BIN} get -u golang.org/x/lint/golint

build-all: dep ## Build binaries for all supported architectures
	for ARCH in $(ARCHS); do \
	  CGO_ENABLED=0 GOOS=linux GOARCH=$$ARCH ${GO_BIN} build -a -ldflags '-extldflags "-static"' -o ${PROJECT_NAME}-$$ARCH $(PKG); \
	done

build: dep ## Build the binary file (default: amd64)
	CGO_ENABLED=0 GOOS=linux GOARCH=${ARCH} ${GO_BIN} build -a -ldflags '-extldflags "-static"' -o ${PROJECT_NAME} $(PKG)

clean: ## Remove previous build
	@rm -f ./maintsrv ./maintsrv-amd64 ./maintsrv-arm64

release: clean dep test race build-all

docker-build:
	${DOCKER_BIN} buildx build -t ${IMAGE_PATH}:$(TAG) . --push

docker-build-local:
	${DOCKER_BIN} buildx build -t ${IMAGE_PATH}:$(TAG) . --load

help: ## Display this help screen
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
