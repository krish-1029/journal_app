# Dockerfile for Actionhero.js API
# This defines how to build the container image for your API

# Use Node.js LTS (Long Term Support) version as base image
# This is like installing Node.js in the container
FROM node:20-alpine

# Set working directory inside the container
# All commands will run from this directory
WORKDIR /app

# Copy package files first (for better Docker caching)
# Docker caches layers - if package.json hasn't changed,
# it won't reinstall node_modules, making builds faster
COPY package*.json ./

# Install ALL dependencies (including devDependencies for TypeScript build)
# We need TypeScript to compile the code
RUN npm ci

# Copy the rest of the application code
# This includes src/, config files, etc.
COPY . .

# Build TypeScript to JavaScript
# The start command needs compiled JS files
RUN npm run build

# Remove devDependencies to reduce image size
# Keep only production dependencies
RUN npm prune --production

# Expose the port your API runs on
# This doesn't actually publish the port - it's documentation
# Docker Compose will map it in docker-compose.yml
EXPOSE 8080

# Set environment to production
ENV NODE_ENV=production

# Command to run when container starts
# This starts your Actionhero server
CMD ["npm", "start"]

