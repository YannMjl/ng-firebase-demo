# -----------------------------------------------------------------*
# Step 1: build the angular app
# -----------------------------------------------------------------*
# We'll name the compilation of stepe 1 as "build"
# so that we are able to refer to it in another step
FROM node as build
LABEL authors="Yann Mulonda"

# update dependencies and install curl
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# both package.json and package-lock.json are copied
# COPY package*.json /app

# This will copy everything from the source path 
# --more of a convenience when testing locally.
COPY . .

# Install app dependencies and build the angular app
RUN npm install -g npm-check-updates \
    ncu -u \
    npm install \
    npm run build --prod

# -----------------------------------------------------------------*
# Step 2: runthe angular app
# -----------------------------------------------------------------*
FROM nginx

# copy the nginx config files
COPY nginx.conf /etc/nginx/nginx.conf

# --from=build, this is "build" form the step 1 
# /app/public, /app is my working directory defined in step 1
# and /public is my "outputPath": "public" defined in my angular.json
# /usr/share/nginx/html this where I want to dump my angular build files
COPY --from=build /app/public /usr/share/nginx/html