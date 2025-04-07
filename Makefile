IMAGE_NAME = mcp_playground

# Helper to extract requirements.lock from container
extract-lock:
	@echo "Delete lock file..."
	rm -f requirements.lock
	@echo "Extracting requirements.lock..."
	@docker create --name temp-extract $$(docker compose -f docker-compose.yaml images -q ${IMAGE_NAME})
	@docker cp temp-extract:/code/requirements.lock .
	@docker rm temp-extract
	@echo "requirements.lock has been extracted"

# Normal build uses existing lock file
build:
	docker compose -f docker-compose.yaml build
	@$(MAKE) extract-lock

# Build with dependency updates
build-update:
	@echo "Setting UPDATE_DEPS=true"
	UPDATE_DEPS=true docker compose -f docker-compose.yaml build --no-cache
	@$(MAKE) extract-lock

up:
	docker compose -f docker-compose.yaml up

build-gpu:
	docker compose -f docker-compose.yaml -f docker-extras/nvidia.yaml build
	@$(MAKE) extract-lock

up-gpu:
	docker compose -f docker-compose.yaml -f docker-extras/nvidia.yaml up

command:
	docker exec -it ${IMAGE_NAME} /bin/bash

command-raw:
	docker compose run ${IMAGE_NAME} bash

command-raw-gpu:
	docker compose -f docker-compose.yaml -f docker-extras/nvidia.yaml run ${IMAGE_NAME} bash

# Update dependencies using uv
requirements-update:
	@echo "Building with fresh dependencies..."
	@echo "Setting UPDATE_DEPS=true"
	UPDATE_DEPS=true docker compose -f docker-compose.yaml build --no-cache
	@$(MAKE) extract-lock

clean-requirements:
	rm -f requirements.lock
