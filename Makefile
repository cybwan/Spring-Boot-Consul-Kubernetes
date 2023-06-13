
DOCKER_BUILDX_OUTPUT ?= type=registry
DOCKER_BUILDX_PLATFORM ?= linux/amd64
CTR_REGISTRY ?= cybwan

.PHONY: buildx-context
buildx-context:
	@if ! docker buildx ls | grep -q "^fsm "; then docker buildx create --name fsm --driver-opt network=host; fi

.PHONY: package-account-service
package-account-service:
	cd account-service;mvn clean package

.PHONY: docker-build-account-service
docker-build-account-service: package-account-service
	docker buildx build --builder fsm --platform=$(DOCKER_BUILDX_PLATFORM) -o $(DOCKER_BUILDX_OUTPUT) \
	-t $(CTR_REGISTRY)/spring-consul-demo:account-service \
	-f dockerfiles/Dockerfile.account-service .

.PHONY: package-customer-service
package-customer-service:
	cd customer-service;mvn clean package

.PHONY: docker-build-customer-service
docker-build-customer-service: package-customer-service
	docker buildx build --builder fsm --platform=$(DOCKER_BUILDX_PLATFORM) -o $(DOCKER_BUILDX_OUTPUT) \
	-t $(CTR_REGISTRY)/spring-consul-demo:customer-service \
	-f dockerfiles/Dockerfile.customer-service .

.PHONY: package-gateway-service
package-gateway-service:
	cd gateway-service;mvn clean package

.PHONY: docker-build-gateway-service
docker-build-gateway-service: package-gateway-service
	docker buildx build --builder fsm --platform=$(DOCKER_BUILDX_PLATFORM) -o $(DOCKER_BUILDX_OUTPUT) \
	-t $(CTR_REGISTRY)/spring-consul-demo:gateway-service \
	-f dockerfiles/Dockerfile.gateway-service .

.PHONY: package-order-service
package-order-service:
	cd order-service;mvn clean package

.PHONY: docker-build-order-service
docker-build-order-service: package-order-service
	docker buildx build --builder fsm --platform=$(DOCKER_BUILDX_PLATFORM) -o $(DOCKER_BUILDX_OUTPUT) \
	-t $(CTR_REGISTRY)/spring-consul-demo:order-service \
	-f dockerfiles/Dockerfile.order-service .

.PHONY: package-product-service
package-product-service:
	cd product-service;mvn clean package

.PHONY: docker-build-product-service
docker-build-product-service: package-product-service
	docker buildx build --builder fsm --platform=$(DOCKER_BUILDX_PLATFORM) -o $(DOCKER_BUILDX_OUTPUT) \
	-t $(CTR_REGISTRY)/spring-consul-demo:product-service \
	-f dockerfiles/Dockerfile.product-service .

DEMO_TARGETS = account-service customer-service gateway-service order-service product-service
DOCKER_DEMO_TARGETS = $(addprefix docker-build-, $(DEMO_TARGETS))
.PHONY: $(DOCKER_DEMO_TARGETS)
$(DOCKER_DEMO_TARGETS): NAME=$(@:docker-build-%=%)

.PHONY: docker-build-demo
docker-build-demo: buildx-context $(DOCKER_DEMO_TARGETS)
