.PHONY: build tag push buildx

build:
	docker build . -t iventoy:build --no-cache

buildx:
	docker buildx build --platform linux/amd64,linux/arm64 . -t iventoy:build --no-cache

tag:
	docker tag iventoy:build garybowers/iventoy:latest
	docker tag iventoy:build garybowers/iventoy:1.0.30

push:
	docker push garybowers/iventoy:latest
	docker push garybowers/iventoy:1.0.30

localtest:
	docker run -it -p 26000:26000 -v /home/gary/developer/isos:/iventoy/iso --privileged --name iventoy_dev  czyt/iventoy:latest
