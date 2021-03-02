SHELL = /bin/sh
.DEFAULT_GOAL=all

DB_CONTAINER = omnisci_test
PYTHON = 3.8
OMNISCI_VERSION = v5.8.0
# OMNISCI_VERSION = latest

-include .env

init:
	mamba env create -f ./environment.yml

init.gpu:
	mamba env create -f ./environment_gpu.yml

update:
	mamba env update -f ./environment.yml

update.gpu:
	mamba env update -f ./environment_gpu.yml

develop:
	pip install -e '.[dev]'
	pre-commit install

start:
	docker run -d --rm --name ${DB_CONTAINER} \
		--ipc=host \
		-p ${OMNISCI_DB_PORT}:6274 \
		-p ${OMNISCI_DB_PORT_HTTP}:6278 \
		omnisci/core-os-cpu:${OMNISCI_VERSION} \
		/omnisci/startomnisci --non-interactive \
		--data /omnisci-storage/data --config /omnisci-storage/omnisci.conf \
		--enable-runtime-udf --enable-table-functions
.PHONY: start

start.gpu:
	docker run -d --rm --name ${DB_CONTAINER} \
		--ipc=host \
		--gpus=0 \
		-p ${OMNISCI_DB_PORT}:6274 \
		-p ${OMNISCI_DB_PORT_HTTP}:6278 \
		omnisci/core-os-cuda:${OMNISCI_VERSION} \
		/omnisci/startomnisci --non-interactive \
		--data /omnisci-storage/data --config /omnisci-storage/omnisci.conf \
		--enable-runtime-udf --enable-table-functions
.PHONY: start.gpu

stop:
	docker stop ${DB_CONTAINER}
.PHONY: stop

down:
	docker rm -f ${DB_CONTAINER}
.PHONY: down

install:
	pip install -e .
.PHONY: install

build:
	python setup.py build
	# pip install -e .
.PHONY: build

check:
	pre-commit
	# black .
	# flake8
 .PHONY: check

test:
	pytest
.PHONY: test

clean:
	python setup.py clean
.PHONY: clean

test_all: init start check test down clean
.PHONY: test_all

all: build
.PHONY: all
