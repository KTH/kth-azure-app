#
# Based on https://gita.sys.kth.se/Infosys/andermatt/tree/master/docker-containers/nodejs/api
#
FROM kthse/kth-nodejs-web

# Maintainer
MAINTAINER Webmaster "webmaster@kth.se"

LABEL name="KTH Node Base Image"
LABEL vendor="KTH Royal Institute of Technology"
LABEL license="The MIT License (MIT)"

RUN mkdir -p /npm
RUN mkdir -p /application

# We do this to avoid npm install when we're only changing code
WORKDIR /npm
COPY package.json package.json
RUN npm install

# Add the code and copy over the node_modules
WORKDIR /
COPY . /application
RUN cp -a /npm/node_modules /application

EXPOSE 3000

ENTRYPOINT [node /application/app.js]
