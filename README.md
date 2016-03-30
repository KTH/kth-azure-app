# kth-azure-app
Reference application for testing in docker cluster

## Prerequisites
* Docker Toolbox >= 1.10.3 (docker 1.10.3, docker-compose 1.6.2) 

## To run
Edit build.sh and add your version number.

Set docker env to point to default (see notes below)

Run ./build.sh

Set docker env to point to cluster (see notes below)

Run docker-compose -p [custom project name with version] up -d


## Notes
If docker can't fetch an image (docker: Network timed out..) [GitHub issue](https://github.com/docker/docker/issues/20910)

`$> docker-machine restart default`

`$> eval $(docker-machine env default)`

If docker-compose up times out, add this to the command:

`$> COMPOSE_HTTP_TIMEOUT=120 docker-compose ...`

If npm fails in build, restart docker locally: 

`$> docker-machine restart default`

Make sure DOCKER_X env variables are set correctly (default) before running build with: 

`$> eval $(docker-machine env default)`

Make sure DOCKER_X env variables are set correctly (cluster) before running compose up: 

`$> DOCKER_CERT_PATH=$HOME/.docker && DOCKER_HOST=core01-service.westeurope.cloudapp.azure.com:4000`

Limitations (and solutions) regarding compose with swarm can be found [here](https://docs.docker.com/compose/swarm/)