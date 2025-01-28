# Use official Node.js image as a base
FROM node:16-alpine

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json (or yarn.lock) to the container
COPY package*.json ./

# Install the app dependencies
RUN npm install --production

# Copy the rest of the application code to the container
COPY . .

# Expose the port the app will run on
EXPOSE 3000

# Build the NestJS app
RUN npm run build

# Start the app
CMD ["npm", "run", "start:prod"]
