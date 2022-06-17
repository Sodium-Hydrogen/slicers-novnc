#!/bin/bash
  
image="sodiumhydrogen/superslicer-novnc"  
  
# Set the timestamp
#timestamp=$(date +%Y.%m.%d.%H%M%S)  
  
tag=$image:$timestamp  
latest=$image:latest  
latest=$image:nightly  
  
# Build the image -- tagged with the timestamp.
docker build -t $latest . --target latest-release
docker build -t $nightly . --target nightly-release
  
# Push with the timestamped tag, and latest image tag to Docker Hub.
docker login
docker push $tag
docker push $latest
  
# Cleanup
docker system prune -f
