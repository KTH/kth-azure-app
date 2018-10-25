#!/bin/bash

passed() { printf "\n\033[0;32m$@\033[0;0m | $(date) \n\n"; }

/Users/patricjansson/dev/kth/gita.sys.kth.se/zermatt/jenkins/docker-rmi-all.sh

passed "Build image with kth-kth-azure-app_app:1.1.1_abcdef"
docker build -q -t kth-azure-app_app --label se.kth.imageName=kth-azure-app --label se.kth.imageVersion=1.1.1_abcdef .

passed "Labels inspected in kth-kth-azure-app_app:1.1.1_abcdef "
docker images | grep kth-azure-app_app | awk '{ print $3 }' | xargs docker inspect | grep se.kth.imageVersion

passed "Run integrations tests"
LOCAL_IMAGE_ID=`docker images | grep kth-azure-app_app | awk '{ print $3 }'` docker-compose &>/dev/null --file docker-compose-integration-tests.yml up  --abort-on-container-exit --always-recreate-deps

docker images

passed "Inspect kth-kth-azure-app_app:1.1.1_abcdef again"
docker images | grep kth-azure-app_app | awk '{ print $3 }' | xargs docker inspect | grep se.kth.imageVersion