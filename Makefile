GOHOSTOS:=$(shell go env GOHOSTOS)
GOPATH:=$(shell go env GOPATH)
VERSION=$(shell git describe --tags --always)
SERVER_NAME="server"
BIN_NAME="server"

#ifeq ($(GOHOSTOS), windows)
#	#the `find.exe` is different from `find` in bash/shell.
#	#to see https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/find.
#	#changed to use git-bash.exe to run find cli or other cli friendly, caused of every developer has a Git.
#	#Git_Bash= $(subst cmd\,bin\bash.exe,$(dir $(shell where git)))
#	Git_Bash=$(subst \,/,$(subst cmd\,bin\bash.exe,$(dir $(shell where git))))
#	INTERNAL_PROTO_FILES=$(shell $(Git_Bash) -c "find internal -name *.proto")
#	API_PROTO_FILES=$(shell $(Git_Bash) -c "find api -name *.proto")
#else
	INTERNAL_PROTO_FILES=$(shell find internal -name *.proto)
	API_PROTO_FILES=$(shell find api -name *.proto)
#endif

.PHONY: init
# init env
init:
	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
	go install github.com/go-kratos/kratos/cmd/kratos/v2@latest
	go install github.com/go-kratos/kratos/cmd/protoc-gen-go-http/v2@latest
	go install github.com/google/gnostic/cmd/protoc-gen-openapi@latest
	go install github.com/google/wire/cmd/wire@latest
	go get github.com/google/wire/cmd/wire@latest
	go install github.com/go-kratos/kratos/cmd/protoc-gen-go-errors/v2@latest

#.PHONY: config
## generate internal proto
#config:
#	protoc --proto_path=./internal \
#	       --proto_path=./third_party \
# 	       --go_out=paths=source_relative:./internal \
#	       $(INTERNAL_PROTO_FILES)

.PHONY: api
# generate api proto
api:
	protoc --proto_path=./api \
	       --proto_path=./third_party \
 	       --go_out=paths=source_relative:./api \
 	       --go-http_out=paths=source_relative:./api \
 	       --go-grpc_out=paths=source_relative:./api \
	       --openapi_out=fq_schema_naming=true,default_response=false:. \
	       $(API_PROTO_FILES)
	printf "servers:\n    - url: http://127.0.0.1:8000\n" >> openapi.yaml


.PHONY: build
# build
build:
	mkdir -p bin/ && CGO_ENABLED=0 go build -mod=readonly -ldflags "-X main.Version=$(VERSION) -X main.Name=$(SERVER_NAME)" -o ./bin/$(BIN_NAME) ./cmd/$(BIN_NAME)

.PHONY: build-linux
# build-linux
build-linux:
	mkdir -p bin/ && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -mod=readonly -ldflags "-X main.Version=$(VERSION) -X main.Name=$(SERVER_NAME)" -o ./bin/$(BIN_NAME) ./cmd/$(BIN_NAME)


.PHONY: generate
# generate
generate:
	go generate ./...
	go mod tidy

.PHONY: all
# generate all
all:
	make api;
	#make config;
	make generate;

.PHONY: api
# generate errors proto
errors:
	protoc --proto_path=. \
			 --proto_path=./third_party \
			 --go_out=paths=source_relative:. \
			 --go-errors_out=paths=source_relative:. \
			 $(API_PROTO_FILES)

.PHONY: docker
# build docker
docker:
	docker build -t $(SERVER_NAME):$(VERSION) -f Dockerfile .

# show help
help:
	@echo ''
	@echo 'Usage:'
	@echo ' make [target]'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
	helpMessage = match(lastLine, /^# (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")); \
			helpMessage = substr(lastLine, RSTART + 2, RLENGTH); \
			printf "\033[36m%-22s\033[0m %s\n", helpCommand,helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help
