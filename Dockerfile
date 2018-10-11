FROM kthse/kth-nodejs:kth-nodejs-web:2.4

COPY ["config", "config"]
COPY ["files", "files"]
COPY ["app.js", "app.js"]
COPY ["package.json", "package.json"]
COPY ["yarn.lock", "yarn.lock"]

RUN cat KTH_OS
RUN cat KTH_NODEJS

RUN yarn install

ENV NODE_PATH /application
EXPOSE 3200

CMD ["node", "app.js"]
