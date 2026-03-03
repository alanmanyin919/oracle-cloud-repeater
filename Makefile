.PHONY: setup copy-files build run shell clean

# Docker image name
IMAGE_NAME = oci-repeater

# Docker container name
CONTAINER_NAME = oci-repeater
PROJECT_DIR := $(shell pwd)

-include .env
export

# Paths
MAIN_TF_EXAMPLE = ./resources/main.tf.example
MAIN_TF = ./resources/main.tf
CONFIG_EXAMPLE = ./resources/config.example
CONFIG = ./resources/config
ENV_EXAMPLE = ./.env.example
ENV_FILE = ./.env

ifeq ($(OS),Windows_NT)
    COPY_CMD = powershell -Command "if (!(Test-Path $(1))) { Copy-Item $(2) $(1) }"
else
    COPY_CMD = if [ ! -f $(1) ]; then cp $(2) $(1); fi
endif

setup: copy-files build run

copy-files:
	$(call COPY_CMD,$(MAIN_TF),$(MAIN_TF_EXAMPLE))
	$(call COPY_CMD,$(CONFIG),$(CONFIG_EXAMPLE))
	$(call COPY_CMD,$(ENV_FILE),$(ENV_EXAMPLE))

build:
	docker build --build-arg TERRAFORM_VERSION=$(TERRAFORM_VERSION) -t $(CONTAINER_NAME) .

run:
	docker run -it -v "$(PROJECT_DIR)/resources:/app/resources" $(CONTAINER_NAME)

shell: run

clean:
	docker stop $(CONTAINER_NAME) || true
	docker kill $(CONTAINER_NAME) || true
	docker rm -f $(CONTAINER_NAME) || true
	docker rmi -f $(IMAGE_NAME) || true
