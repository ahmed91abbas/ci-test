DOCKER_IMAGE = main-sum


.PHONY: build
build:
	@echo "Docker Build..."
	docker build -t $(DOCKER_IMAGE) .

.PHONY: test
test: build
	docker run --rm\
		-v $(realpath ./tests):/src/tests \
		${DOCKER_IMAGE} -m pytest tests

.PHONY: lint
lint: build
	docker run --rm \
		${DOCKER_IMAGE} -m flake8 ./
