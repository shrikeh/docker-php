#!make
ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

.EXPORT_ALL_VARIABLES:
.ONESHELL:
.DEFAULT: help
.PHONY: help
ifndef VERBOSE
.SILENT:
endif

init:
	$(info [+] Make: Installing all host dependencies and configuring project)
	brew bundle install --quiet;
	mise trust > /dev/null 2>&1;
	direnv allow > /dev/null 2>&1;
	${MAKE} --no-print-directory dotenv-local envrc-local;
	direnv reload
	pre-commit install


dotenv-local:
	bash -c "[ -f './.env.local' ] || ${MAKE} .create-env-local";

envrc-local:
	bash -c "[ -f './.envrc.local' ] || ${MAKE} .create-envrc-local";

.create-env-local:
	$(info [+] Make: Creating .env.local from template)
	docker compose run --quiet --remove-orphans --rm gomplate --file "/templates/.env.local.tpl" --out "/output/.env.local"

.create-envrc-local:
	$(info [+] Make: Creating .envrc.local from template)
	docker compose run --quiet --remove-orphans --rm gomplate --file "/templates/.envrc.local.tpl" --out "/output/.envrc.local"

push-image:
	$(info [+] Make: Pushing to ghcr.io...)
	docker compose push

build-image:
	$(info [+] Make: Building docker image...)
	docker compose build

login:
	$(info [+] Make: Logging into docker container...)
	docker compose run --remove-orphans -it "${APP_CONTAINER}" /bin/sh

up:
	docker compose up --remove-orphans -d
