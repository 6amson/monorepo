FROM node:18-alpine

WORKDIR /usr/src/app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy all source files
COPY . .

# Build the app using local nest cli
RUN npm run build

# Start the app
EXPOSE 3000
CMD [ "npm", "run", "start:prod" ]