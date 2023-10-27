FROM node:20.8.1-alpine3.17

WORKDIR /d3fau1t
COPY app/node/package.json app/node/package-lock.json ./
COPY app/python/redis-client ./redis-client
RUN npm install
