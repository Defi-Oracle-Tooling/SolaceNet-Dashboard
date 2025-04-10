# Use a Node base image
FROM node:18-alpine

# Create app directory
WORKDIR /app

# Copy package.json & package-lock.json first to leverage Docker cache
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Copy the rest of the source code
COPY . .

# Build the project
RUN npm run build

# Expose port
EXPOSE 3000

# Start the app (you may adjust the command if your app runs differently)
CMD ["npm", "run", "dev"]
