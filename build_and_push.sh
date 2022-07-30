#!/bin/bash
  
image="sodiumhydrogen/superslicer-novnc"  

LATEST_URL="https://api.github.com/repos/supermerill/SuperSlicer/releases/latest"
ALL_RELEASES_URL="https://api.github.com/repos/supermerill/SuperSlicer/releases"

ltag="$(curl -SsL {$LATEST_URL} | jq -r ".tag_name")"
ptag="$(curl -SsL {$ALL_RELEASES_URL} | jq -r "first | .tag_name")"

latest=$image:latest
latest_version=$image:$ltag

prerelease=$image:prerelease
prerelease_version=$image:prerelease-$ptag

# Build the image -- tagged with the timestamp.
docker build -t $latest -t $latest_version . --target latest-release
docker build -t $prerelease -t $prerelease_version . --target tagged-release --build-arg VERSION=$ptag
  
# Push with the timestamped tag, and latest image tag to Docker Hub.
docker login
docker push $tag
docker push $latest
  
# Cleanup
docker system prune -f
