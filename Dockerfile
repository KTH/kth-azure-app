FROM kthse/kth-nodejs:12.0.0

COPY ["config", "config"]
COPY ["modules", "modules"]
COPY ["app.js", "app.js"]
COPY ["pac kage.json", "package.json"]

RUN cat KTH_OS
RUN cat KTH_NODEJS

RUN npm install --production

ENV NODE_PATH /application
EXPOSE 3000

CMD ["node", "app.js"]
