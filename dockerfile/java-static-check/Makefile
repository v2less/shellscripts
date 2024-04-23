NS ?= freelxs
IMAGE_NAME ?= java-static-check
VERSION ?= latest
CONTAINER_NAME ?= $(IMAGE_NAME)
CONTAINER_INSTANCE ?= default
WORK_DIR ?= target
TARGET_DIR ?= $(WORK_DIR)/opt

.PHONY: build shell clean

# Utility targets
clean:
		rm -rf $(WORK_DIR)
$(WORK_DIR): $(TARGET_DIR)

$(TARGET_DIR):
		mkdir -p $(TARGET_DIR)

## Build
build: Dockerfile
		docker build -t $(NS)/$(IMAGE_NAME):$(VERSION) -f Dockerfile --build-arg TARGET_DIR=$(TARGET_DIR) .

## Test in shell with latest build
shell: build
		docker run --rm --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) -i -t $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION) /bin/sh

default: build
