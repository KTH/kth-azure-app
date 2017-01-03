FROM kthse/kth-nodejs-web:2.0-alpine

MAINTAINER KTH Webb "cortina.developers@kth.se"

RUN mkdir -p /npm   && \
    mkdir -p /application


# We do this to avoid npm install when we're only changing code
WORKDIR /npm

COPY ["package.json", "package.json"]

RUN npm install

# Add the code and copy over the node_modules

WORKDIR /application
COPY ["app.js", "app.js"]
COPY ["config", "config"]

RUN cp -a /npm/node_modules /application

EXPOSE 3000

ENV NODE_PATH /application

ENTRYPOINT ["node", "app.js"]
