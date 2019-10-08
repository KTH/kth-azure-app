FROM kthse/kth-nodejs:10.14.0

RUN apk --no-cache add --virtual native-deps \
    g++ gcc libgcc libstdc++ linux-headers make python && \
    npm install --quiet node-gyp -g &&\
    npm install --quiet  && \
    apk del native-deps python make libstdc++ g++ gcc libgcc --virtual native-deps

COPY ["config", "config"]
COPY ["files", "files"]
COPY ["app.js", "app.js"]
COPY ["package.json", "package.json"]
COPY ["yarn.lock", "yarn.lock"]

RUN cat KTH_OS
RUN cat KTH_NODEJS

RUN npm install

ENV NODE_PATH /application
EXPOSE 3000

CMD ["node", "app.js"]
