#!/usr/bin/env bash

docker-machine create -d virtualbox keystore

docker $(docker-machine config keystore) run -d \
    -p 8500:8500 \
    -h consul \
    --name consul \
    progrium/consul -server -bootstrap

docker-machine create -d virtualbox \
    --engine-opt="cluster-store=consul://$(docker-machine ip keystore):8500" \
    --engine-opt="cluster-advertise=eth1:2376" \
    devenv