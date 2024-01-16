#!/bin/bash
# Get the latest release of SuperSlicer for Linux (non-AppImage) using the GitHub API
# This was forked from https://github.com/helfrichmichael/prusaslicer-novnc/blob/main/get_latest_prusaslicer_release.sh

set -eu

if [[ $# -lt 1 ]]; then
  echo "~~~ $0 ~~~"
  echo "	usage: $0 [ url | name | url_ver VERSION | name_ver VERSION_NAME ]"
  echo
  echo "	url: Returns the download URL for the latest release (for download using cURL/wget)"
  echo "	name: Returns the filename of the latest release"
  echo 
  echo "	url_ver: Takes a parameter to specify the version to retrieve (note: Version 53 has the new file format so anything older wont work.)"
  echo "	url_ver example: $0 url_ver 2.2.53.3"
  echo "	output: https://github.com/supermerill/SuperSlicer/releases/download/2.2.53.3/SuperSlicer_2.2.53.3_linux64_20201005.zip"
  echo
  echo "	name_ver: Takes a parameter to specify the filename to retrieve"
  echo "	name_ver example: $0 name_ver 2.2.53.3"
  echo "	output: SuperSlicer_2.2.53.3_linux64_20201005.zip"
  echo
  exit 1
fi

baseDir="/tmp"
mkdir -p $baseDir

if [[ ! -e "$baseDir/latestReleaseInfo.json" ]]; then

  curl -SsL https://api.github.com/repos/prusa3d/PrusaSlicer/releases/latest > $baseDir/latestReleaseInfo.json

fi

releaseInfo=$(cat $baseDir/latestReleaseInfo.json)

if [[ $# -gt 1 ]]; then

  VER=$(echo $2 | perl -pe 's/^version_(.*)/\1/g' )

  if [[ ! -e "$baseDir/releases.json" ]]; then
    curl -SsL https://api.github.com/repos/prusa3d/PrusaSlicer/releases > $baseDir/releases.json
  fi

  allReleases=$(cat $baseDir/releases.json)

fi

if [[ "$1" == "url" ]]; then

  echo "${releaseInfo}" | jq -r '.assets[] | .browser_download_url | select(test("PrusaSlicer-[0-9.]+%2Blinux-x64-GTK3-\\d+\\.tar\\.bz2"))'

elif [[ "$1" == "name" ]]; then

  echo "${releaseInfo}" | jq -r '.assets[] | .name | select(test("PrusaSlicer-[0-9.]+\\+linux-x64-GTK3-\\d+\\.tar\\.bz2"))'

elif [[ "$1" == "url_ver" ]]; then

  # Note: Releases sometimes have hex-encoded ascii characters tacked on
  # So version '2.0.0+' might need to be requested as '2.0.0%2B' since GitHub returns that as the download URL
  echo "${allReleases}" | jq --arg VERSION "$VER" -r '.[] | .assets[] | .browser_download_url | select(test("PrusaSlicer-" + $VERSION + "%2Blinux-x64-GTK3-\\d+\\.tar\\.bz2"))'

elif [[ "$1" == "name_ver" ]]; then
   
  echo "${allReleases}" | jq --arg VERSION "$VER" -r '.[] | .assets[] | .name | select(test("PrusaSlicer-" + $VERSION + "\\+linux-x64-GTK3-\\d+\\.tar\\.bz2"))'

fi
