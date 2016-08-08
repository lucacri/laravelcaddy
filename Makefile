TAG := latest
IMAGE := lucacri/laravelcaddy

build:
	@docker build -t ${IMAGE}:${TAG} .

push:
	@docker push ${IMAGE}:${TAG}
