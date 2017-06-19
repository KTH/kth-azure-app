FROM kthse/kth-nodejs-web:2.3

MAINTAINER KTH Webb "cortina.developers@kth.se"

LABEL se.kth.slack="#team-kth-web"

RUN mkdir -p /npm && \
    mkdir -p /application

# We do this to avoid npm install when we're only changing code
WORKDIR /npm
COPY ["package.json", "package.json"]
COPY ["yarn.lock", "yarn.lock"]
RUN yarn install --production --no-optional

# Add the code and copy over the node_modules-catalog.
WORKDIR /application
RUN cp -a /npm/node_modules /application && \
    cp /npm/package.json /application/package.json && \
    cp /npm/yarn.lock /application/yarn.lock && \
    rm -rf /npm

# Copy files used by Gulp.
COPY ["config", "config"]
COPY ["app.js", "app.js"]

ENV NODE_PATH /application

EXPOSE 3200

ENTRYPOINT ["node", "app.js"]
