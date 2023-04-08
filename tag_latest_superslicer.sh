#!/bin/bash
# Push a tag for our repository if upstream SuperSlicer generates a new release
# This was forked from https://github.com/helfrichmichael/prusaslicer-novnc/blob/main/tag_latest_prusaslicer.sh

set -eu

# ** start of configurable variables **

# GH_ACTION -- indicates that we are running in a github action, and instead of pushing, just use
# return codes to indicate whether or not continuing with the workflow is appropriate
GH_ACTION="y"

# LATEST_RELEASE -- where to find the latest SuperSlicer release
LATEST_RELEASE="https://api.github.com/repos/supermerill/SuperSlicer/releases"

# ** end of configurable variables **

# Get the latest tagged version
CURL_TEXT="$(curl -SsL ${LATEST_RELEASE} )"
LATEST_VERSION="$(echo $CURL_TEXT | jq -r 'first | .tag_name')"

if [[ -z "${LATEST_VERSION}" ]] || [[ "${LATEST_VERSION}" == "null" ]]; then

  echo "Could not determine the latest version."
  echo "Has release naming changed from previous conventions?"
  echo "${LATEST_VERSION}"
  echo -e "\n\n"
  echo "$(echo $CURL_TEXT)"
  exit 1

fi


# Run from the git repository
cd "$(dirname "$0")";

# Get the latest tag (by tag date, not commit) in our repository
LATEST_GIT_TAG=$(git for-each-ref refs/tags --sort=-creatordate --format='%(refname:short)' --count=1)

if [[ "${LATEST_GIT_TAG}" != "${LATEST_VERSION}" ]]; then

  echo "Update needed. Latest tag ver: ${LATEST_GIT_TAG} != upstream ver: ${LATEST_VERSION} .."
  git tag "${LATEST_VERSION}"

  git push --tags
  exit 0

else

  echo "Latest tag ver: ${LATEST_GIT_TAG} == upstream ver: ${LATEST_VERSION} -- no update"
  exit 0

fi
