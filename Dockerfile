FROM kthse/kth-nodejs-web:4.4

COPY ["config", "config"]
COPY ["files", "files"]
COPY ["app.js", "app.js"]
COPY ["package.json", "package.json"]
COPY ["yarn.lock", "yarn.lock"]

RUN yarn install

ENV NODE_PATH /application
EXPOSE 3200

CMD ["node", "app.js"]
