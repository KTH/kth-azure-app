FROM kthse/kth-nodejs:16.0.0

RUN cat KTH_OS
RUN cat KTH_NODEJS

COPY ["package.json", "package.json"]

RUN npm install --production && \
    npm prune

COPY ["config", "config"]
COPY ["modules", "modules"]
COPY ["app.js", "app.js"]

ENV NODE_PATH /application
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s CMD curl -f http://localhost:3000/kth-azure-app/_about || exit 1

CMD ["node", "app.js"]
