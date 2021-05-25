FROM node:10

COPY . /app

WORKDIR /app
RUN npm install

EXPOSE 3000
USER nobody
ENV SECRET_WORD TwelveFactor

CMD ["npm", "start"]