FROM kthse/kth-nodejs-web:1.4

RUN mkdir -p /npm
RUN mkdir -p /application

# We do this to avoid npm install when we're only changing code
WORKDIR /npm
COPY package.json package.json
RUN npm install

# Add the code and copy over the node_modules
WORKDIR /
COPY . /application
RUN cp -a /npm/node_modules /application

EXPOSE 3000

ENTRYPOINT ["node", "/application/app.js"]
