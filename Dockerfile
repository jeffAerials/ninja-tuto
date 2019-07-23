#########################
### build environment ###
#########################

# base image
FROM node:11.13.0 as builder

# RUN node --version

# set working directory
RUN mkdir /usr/src/app
WORKDIR /usr/src/app

ARG NODE_ENV
ENV NODE_ENV $NODE_ENV

# add `/usr/src/app/node_modules/.bin` to $PATH
ENV PATH /usr/src/app/node_modules/.bin:$PATH

# install and cache app dependencies
COPY package.json /usr/src/app/package.json
RUN npm install
RUN npm install -g @angular/cli --unsafe

# RUN ng --version

# add app
COPY . /usr/src/app

# generate build
RUN npm run build

##################
### production ###
##################

# base image
FROM nginx:alpine

# copy artifact build from the 'build environment'
COPY --from=builder /usr/src/app/dist/* /usr/share/nginx/html

# change the configuratin file nginx to open port 5000
COPY ./nginx.config /etc/nginx/conf.d/default.conf

# expose port 5000 for GitLab and Kubernetes
EXPOSE 5000

# run nginx to activate http connection while deployement
CMD ["nginx", "-g", "daemon off;"]
