REPO?=112243728910.dkr.ecr.eu-west-1.amazonaws.com/platform
IMAGE?=aws-encryption-provider
TAG?=v0.1.0

.PHONY: lint test build-docker build-server build-client

lint:
	echo "Verifying go mod tidy"
	hack/verify-mod-tidy.sh
	echo "Verifying vendored dependencies"
	hack/verify-vendor.sh
	echo "Verifying gofmt"
	hack/verify-gofmt.sh
	echo "Verifying linting"
	hack/verify-golint.sh

test:
	go test -mod vendor -v -cover -race ./...

build-docker:
	docker build \
		-t ${REPO}/${IMAGE}:latest \
		-t ${REPO}/${IMAGE}:${TAG} \
		--build-arg TAG=${TAG} .

build-server:
	go build -mod vendor -ldflags \
			"-w -s -X sigs.k8s.io/aws-encryption-provider/pkg/version.Version=${TAG}" \
			-o bin/aws-encryption-provider cmd/server/main.go

build-client:
	go build -mod vendor -ldflags "-w -s" -o bin/grpcclient cmd/client/main.go

