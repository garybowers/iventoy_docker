.PHONY: build tag push

build:
	docker build . -t iventoy:build

tag:
	docker tag iventoy:build garybowers/iventoy:latest
	docker tag iventoy:build garybowers/iventoy:1.0.09

push:
	docker push garybowers/iventoy:latest
	docker push garybowers/iventoy:1.0.09

