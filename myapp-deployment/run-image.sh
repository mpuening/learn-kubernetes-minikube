#!/bin/sh

#sudo docker run -it --entrypoint /bin/bash myapp

#sudo docker ps
#sudo docker stop 12345

sudo docker run -d -p 8080:8080 myapp

