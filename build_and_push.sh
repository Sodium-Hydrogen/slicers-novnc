#!/bin/bash
# 
# Supported args are --push/--prune
  
image="sodiumhydrogen/superslicer-novnc"  

LATEST_URL="https://api.github.com/repos/supermerill/SuperSlicer/releases/latest"
ALL_RELEASES_URL="https://api.github.com/repos/supermerill/SuperSlicer/releases"

ltag="$(curl -SsL {$LATEST_URL} | jq -r ".tag_name")"
ptag="$(curl -SsL {$ALL_RELEASES_URL} | jq -r "first | .tag_name")"

latest=$image:latest
latest_version=$image:$ltag

prerelease=$image:prerelease
prerelease_version=$image:prerelease-$ptag
prerelease_major=$image:"$(echo $ptag | perl -pe 's/^(\d+.\d+).*/\1/g' )"

# Build the image -- tagged with the timestamp.
docker build -t $latest -t $latest_version . --target latest-release
docker build -t $prerelease -t $prerelease_version -t $prerelease_major . --target tagged-release --build-arg VERSION=$ptag
  
# accept --push to push
if [[ " $@ " =~ " --push " ]]; then
	# Push with the timestamped tag, and latest image tag to Docker Hub.
	docker login
	docker push $latest
	docker push $latest_version
	docker push $prerelease
	docker push $prerelease_version
	docker push $prerelease_major
	  
fi

# accept --prune to prune
if [[ " $@ " =~ " --prune " ]]; then
	# Cleanup
	docker system prune -f
fi
