FROM kthse/kth-nodejs:8.11.0
#FROM kthse/kth-nodejs:10.14.0

COPY ["config", "config"]
COPY ["modules", "modules"]
COPY ["app.js", "app.js"]
COPY ["package.json", "package.json"]

RUN cat KTH_OS
RUN cat KTH_NODEJS

RUN npm install

ENV NODE_PATH /application
EXPOSE 3000

CMD ["node", "app.js"]
