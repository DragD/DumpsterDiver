SHELL := /bin/bash
MAKEFLAGS += --warn-undefined-variables

TAG=alpine3.15
IMG_REPO=us.icr.io/image-hub

IMG_DD_BASE=${IMG_REPO}/python
IMG_DD=${IMG_REPO}/dumpsterdiver

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

image:
	@echo "Building container image..."
	docker build ${common_build_args} ${labels} 											\
				--label=BaseImage=${IMG_DD_BASE}:${TAG} 				\
				--label=Dockerfile=${GIT_REPO}/Dockerfile 									\
				--build-arg BASE_IMAGE=${IMG_DD_BASE}:${TAG}		\
				-t ${IMG_DD}:${TAG}																					\
				-f Dockerfile	.

push:
	@echo "Pushing container image..."
	docker push ${IMG_DD}:${TAG}
	ibmcloud cr image-tag ${IMG_DD}:${TAG} ${IMG_DD}:${DATE_TAG}

va:
	@echo "Vulnerability Assessment status"
	ibmcloud cr va ${IMG_DD}:${TAG}

scan:
	@echo "Scanning current folder..."
	docker run -it --rm                   \
		-v /home/dragd/git/si-services:/vul \
		-v /home/dragd/git/DumpsterDiver/config.yaml:/config.yaml \
		${IMG_DD}:${TAG} \
	  python DumpsterDiver.py	-p /vul -o /vul/dumpsterdiver.json --entropy=5
