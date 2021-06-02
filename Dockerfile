FROM kthse/kth-nodejs:14.0.0

COPY ["package.json", "package.json"]

RUN npm install --production && \
    npm prune

COPY ["config", "config"]
COPY ["modules", "modules"]
COPY ["app.js", "app.js"]

RUN cat KTH_OS
RUN cat KTH_NODEJS

ENV NODE_PATH /application
EXPOSE 3000

CMD ["node", "app.js"]
