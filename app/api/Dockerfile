FROM node:16.10-alpine AS builder
ENV NODE_ENV production

# Add a work directory
WORKDIR /app

# Copy these over first so we don't repeat yarn install for code changes
COPY package.json package.json

# Install dependencies
RUN yarn install --production

# Copy app files
COPY . .

# Build the app
RUN yarn build

EXPOSE 3000

CMD [ "node", "app.js" ]
