namespace :=laravel
export commit_hash=$(shell git log -n1 --oneline | awk '{print $$1}')

build: info
	docker-compose build

rm-build:
	docker-compose down --rmi all

push:
	docker-compose push

info: commit_hash

commit_hash:
	git log -n1 --oneline | awk '{print $$1}' > commit_hash
	export commit_hash=`cat commit_hash`

release: info
	helm package ../../mychart --app-version `cat commit_hash` -d release

deploy:
	helm upgrade --install --namespace $(namespace) mychart release/* -f ../../mychart/values.yaml
