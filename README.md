# Reference and Monitoring Application for the Docker Swarm Cluster
This is an application for testing that the [Docker Swarm cluster](https://gita.sys.kth.se/infosys/kth-azure-swarm) on Azure works as intended.

### Available as Docker
![](https://gita.sys.kth.se/Infosys/beldersay/blob/master/docs/img/docker-small.png)

[Versions](https://kth-docker-registry.sys.kth.se/v2/kth-azure-app/tags/list)

```json
docker pull kth-docker-registry.sys.kth.se/kth-azure-app
```

## Prerequisites
* Docker version 1.11.0 or later
* Docker-compose 1.7.0 or later

## To run
Edit build.sh and add your version number.

Set docker env to point to default (see notes below)

Run ./build.sh

Set docker env to point to cluster (see notes below)

Run docker-compose -p [custom project name with version] up -d

## Development workflow

1. Dev created Dockerfile and docker-compose.yml
  * How to communicate andermatt base images?
  * How to issue creation of new andermatt base images?
  * Who owns andermatt?
  * How to communicate extensions 
2. Dev makes change to code and wants to test locally
  * Is the Dockerfile compatible for both cluster and local?
  * How to handle overlay networks that require a kv-store?
  * How to handle DNS entries created for compose services connect('redis')?
3. Dev pushes code changes to gita
  * 

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
