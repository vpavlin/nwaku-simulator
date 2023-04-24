FROM docker.io/library/node:current-alpine3.17

WORKDIR /opt/websockets

COPY package.json yarn.lock /opt/websockets/

RUN yarn install

ENV NODE_TLS_REJECT_UNAUTHORIZED=0

COPY index.js ./index.js

CMD ["index.js"]
