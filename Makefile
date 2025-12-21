.PHONY: set-version push deploy undeploy help

VERSION ?= $(shell curl -s https://api.github.com/repos/stefanprodan/podinfo/releases/latest | grep '"tag_name":' | cut -d'"' -f4)
IMAGE := ghcr.io/stefanprodan/podinfo
ARTIFACT := oci://ghcr.io/stefanprodan/manifests/podinfo-deploy

# Detect OS for sed compatibility
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
	SED_INPLACE := sed -i ''
else
	SED_INPLACE := sed -i
endif

help:
	@echo "Usage:"
	@echo "  make set-version VERSION=<version>  - Update podinfo image version"
	@echo "  make push VERSION=<version>         - Push OCI artifact to registry"
	@echo "  make deploy                         - Deploy to Kubernetes with Flux Operator"
	@echo "  make undeploy                       - Remove deployment from Kubernetes"
	@echo ""
	@echo "Example:"
	@echo "  make set-version VERSION=6.10.0"
	@echo "  make push VERSION=6.10.0"

set-version:
	@echo "Setting podinfo version to $(VERSION)"
	@find kubernetes -name "*.yaml" -exec $(SED_INPLACE) 's|$(IMAGE):[0-9]*\.[0-9]*\.[0-9]*|$(IMAGE):$(VERSION)|g' {} \;
	@echo "Done. Updated files:"
	@grep -r "$(IMAGE):$(VERSION)" kubernetes --include="*.yaml" -l

push:
	@echo "Pushing OCI artifact with version $(VERSION)"
	flux push artifact $(ARTIFACT):$(VERSION) \
		--path="./kubernetes" \
		--source="$$(git config --get remote.origin.url)" \
		--revision="$$(git branch --show-current)@sha1:$$(git rev-parse HEAD)"
	flux tag artifact $(ARTIFACT):$(VERSION) \
		--tag latest

deploy:
	@echo "Deploying to Kubernetes"
	kubectl create namespace apps --dry-run=client -o yaml | kubectl apply --server-side -f -
	kubectl apply --server-side -f flux/deploy.yaml

undeploy:
	@echo "Removing deployment from Kubernetes"
	kubectl delete -f flux/deploy.yaml --ignore-not-found
