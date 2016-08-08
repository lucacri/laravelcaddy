TAG := latest
IMAGE := docker.paypertrail.com/paypertrail/webcaddy

build:
	@docker build -t ${IMAGE}:${TAG} .

push:
	@docker push ${IMAGE}:${TAG}
