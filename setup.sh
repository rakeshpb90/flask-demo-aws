#!/bin/bash
#create the docker image
sudo docker build --tag flask-docker-demo-app .
#start the container
sudo docker  run --name flask-docker-demo-app -d -p 5001:5001 flask-docker-demo-app
