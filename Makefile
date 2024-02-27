IMAGE=ghcr.io/kwkoo/yolov8-orin
BUILDERNAME=multiarch-builder

BASE:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

.PHONY: run run-docker image

run:
	podman run \
	  --rm \
	  -it \
	  --name yolo \
	  --device /dev/video0 \
	  -p 8080:8080 \
	  --runtime /usr/bin/nvidia-container-runtime \
	  --group-add keep-groups \
	  --security-opt label=disable \
	  --env NVIDIA_DRIVER_CAPABILITIES=all \
	  $(IMAGE)

run-docker:
	docker run \
	  --name yolo \
	  --rm \
	  -it \
	  -p 8080:8080 \
	  -e CAMERA=/video/sample.mp4 \
	  -v $(BASE):/video \
	  $(IMAGE)

image:
	-mkdir -p $(BASE)/docker-cache
	docker buildx use $(BUILDERNAME) || docker buildx create --name $(BUILDERNAME) --use
	docker buildx build \
	  --push \
	  --platform=linux/amd64,linux/arm64 \
	  --cache-to type=local,dest=$(BASE)/docker-cache,mode=max \
	  --cache-from type=local,src=$(BASE)/docker-cache \
	  --rm \
	  -t $(IMAGE) \
	  $(BASE)
