IMAGE_NAME = 

build:
	docker compose -f docker-compose.yaml build

up:
	docker compose -f docker-compose.yaml up

build-gpu:
	docker compose -f docker-compose.yaml -f docker-extras/nvidia.yaml build

up-gpu:
	docker compose -f docker-compose.yaml -f docker-extras/nvidia.yaml up

command:
	docker exec -it ${IMAGE_NAME} /bin/bash

command-raw:
	docker compose run ${IMAGE_NAME} bash

command-raw-gpu:
	docker compose -f docker-compose.yaml -f docker-extras/nvidia.yaml run ${IMAGE_NAME} bash
