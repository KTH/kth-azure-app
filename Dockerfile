# Vilken bas image ska projektet köras i?
FROM kthse/kth-nodejs-web:2.0-pre

# Kopiera in filer som ska köras på servern.
COPY app.js app.js
COPY package.json package.json

# Installera packet
RUN npm install

# Öppna upp en port som kan mappas från värdmaskinen.
EXPOSE 3000

# Kommando som ska köras när den färdiga image:en startas.
ENTRYPOINT ["node", "app.js"]
