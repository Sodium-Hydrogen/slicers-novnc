#!/bin/bash
# 
# Supported args are --push/--prune
  

if [[ " $@ " =~ " orcaslicer " ]]; then
	SLICER="orcaslicer"
	REPO="SoftFever/OrcaSlicer"
elif [[ " $@ " =~ " prusaslicer " ]]; then
	SLICER="prusaslicer"
	REPO="prusa3d/PrusaSlicer"
elif [[ " $@ " =~ " superslicer " ]]; then
	SLICER="superslicer"
	REPO="supermerill/SuperSlicer"
else
	bash $0 orcaslicer $@
	bash $0 prusaslicer $@
	bash $0 superslicer $@
	exit 1
fi

image="sodiumhydrogen/slicers-novnc"  

LATEST_URL="https://api.github.com/repos/${REPO}/releases/latest"
ALL_RELEASES_URL="https://api.github.com/repos/${REPO}/releases"

ltag="$(curl -SsL {$LATEST_URL} | jq -r ".tag_name")"
ptag="$(curl -SsL {$ALL_RELEASES_URL} | jq -r "first | .tag_name")"

latest=${image}:${SLICER}
latest_version=${image}:${SLICER}-"$(echo $ltag | perl -pe 's/^[vV]?(ersion_)?(.*)/\2/g' )"

prerelease=${image}:${SLICER}-prerelease
prerelease_version=${image}:${SLICER}-prerelease-"$(echo $ptag | perl -pe 's/^[vV]?(ersion_)?(.*)/\2/g' )"
prerelease_major=${image}:${SLICER}-"$(echo $ptag | perl -pe 's/^([vV]|version_)?(\d+.\d+).*/\2/g' )"

# Build the image -- tagged with the timestamp.
docker build -t $latest -t $latest_version . --target latest-release --build-arg SLICER=${SLICER}
docker build -t $prerelease -t $prerelease_version -t $prerelease_major . --target tagged-release --build-arg SLICER=${SLICER} --build-arg VERSION=$ptag
  
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
