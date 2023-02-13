SHELL := /bin/bash
MAKEFLAGS += --warn-undefined-variables

TAG=3.11.2-alpine3.17
IMAGE_NAME=dumpsterdiver
IMAGE_REPO=us.icr.io/image-hub
IMG_TAG=${IMAGE_REPO}/${IMAGE_NAME}:${TAG}
DOCKERFILE=Dockerfile

IMG_TAG_BASE=${IMAGE_REPO}/python:${TAG}

container_name=dumpsterdiver

GIT_REPO=$(shell   basename -s .git `git config --get remote.origin.url`)
GIT_BRANCH=$(shell git rev-parse --abbrev-ref HEAD)
GIT_COMMIT=$(shell git log -1 --format=%h)
BUILT_BY=$(shell   git config --get user.name | sed "s/ /-/g")
DATE_TAG=$(shell   date -u +"%Y-%m-%d")

common_build_args=--build-arg=GIT_COMMIT=Branch--${GIT_BRANCH}--Commit--${GIT_COMMIT} \
									--build-arg=BUILT_BY=${BUILT_BY}

labels=--label=BuiltBy=${BUILT_BY} 			\
				--label=GitRepo=${GIT_REPO} 		\
				--label=GitBranch=${GIT_BRANCH}	\
				--label=GitCommit=${GIT_COMMIT}

REPOS_DIR=${HOME}/git

image:
	@echo "Building container image..."
	docker build ${common_build_args} ${labels} 	\
				--label=Version=${TAG}									\
				--label=BaseImage=${IMG_TAG_BASE}				\
				--label=Dockerfile=${DOCKERFILE} 				\
				--build-arg=BASE_IMAGE=${IMG_TAG_BASE}	\
				--no-cache --pull 											\
				-t ${IMG_TAG}														\
				-f Dockerfile	.

run:
	@echo "Scanning current folder..."
	docker run -it --rm --name ${container_name} 													\
		-v ${REPOS_DIR}/si-services:/vul																		\
		${IMG_TAG} 																													\
		python DumpsterDiver.py	-p /vul -o /vul/dumpsterdiver.json 					\
				--entropy=5	--exclude-files .scss .css .map

push:
	@echo "Pushing image..."
	docker push ${IMG_TAG}
	ibmcloud cr image-tag ${IMG_TAG}  ${IMAGE_REPO}/${IMAGE_NAME}:${DATE_TAG}
	oc tag ${IMG_TAG}  									  image-hub/${IMAGE_NAME}:${TAG}  --reference-policy=local --scheduled
	@sleep 5
	oc tag image-hub/${IMAGE_NAME}:${TAG} image-hub/${IMAGE_NAME}:latest

va:
	@echo "Vulnerability Assessment status..."
	ibmcloud cr va ${IMG_TAG}

# Check if a variable is set
check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined variable $1$(if $2, ($2))))