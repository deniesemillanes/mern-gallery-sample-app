# Use Node.js 18 as the base image
FROM node:18

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json to the container
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the server files to the container
COPY . /opt/nodejs

# Expose the server port
EXPOSE 5000

# Start the server
CMD [ "node", "index.js" ]
