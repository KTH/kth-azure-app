FROM kthse/kth-nodejs-web:2.3

MAINTAINER "#team-pipeline"

LABEL se.kth.slack="#team-kth-web"

FROM kthse/kth-nodejs-web:2.

MAINTAINER KTH Webb "webmaster@kth.se"

# Copy files used by Gulp.
COPY ["config", "config"]
COPY ["app.js", "app.js"]
COPY ["package.json", "package.json"]
COPY ["yarn.lock", "yarn.lock"]

RUN yarn install

ENV NODE_PATH /application

EXPOSE 3200

ENTRYPOINT ["node", "app.js"]
