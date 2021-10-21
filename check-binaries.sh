#!/bin/bash

set -e

RED='\033[1;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'
UND='\033[4m'

#  vars
declare -a REQ_BINARIES=()

# functions
init(){
    while read binary
    do
      if [[ ! ${binary} =~ "#" ]] && [[ ! ${binary} == "" ]] ; then
            REQ_BINARIES+=( "${binary}" )
      fi
    done < ./versions.txt
}

check_required_binaries() {
  init

  printf "*********************************\n"
  printf "${UND}Checking required binaries:${NC}\n"

  FAILED_INSTALL=""
  FAILED_VERSION=""
  SUCCESS="true"

  for BINARY_VERSIONS in "${REQ_BINARIES[@]}"
  do
    BINARY="${BINARY_VERSIONS%%:*}"
    VERSION="${BINARY_VERSIONS##*:}"

    if [ ! -z $(which ${BINARY}) ] ; then
        INSTALLED_VERSION=$(get_binary_version ${BINARY})
        if [  "${INSTALLED_VERSION}" != "${VERSION}" ] && [ "${VERSION}" != "*" ] ; then
            FAILED_VERSION="Installed: ${BINARY}["${INSTALLED_VERSION}"] | Required: ${BINARY}["${VERSION}"]\n${FAILED_VERSION}"
            SUCCESS="false"
        fi
    else
      FAILED_INSTALL="Binary: ${BINARY} | Version: ${VERSION}\n${FAILED_INSTALL}"
      SUCCESS="false"
    fi
  done

  if [ "${SUCCESS}" = "true" ] ; then
    printf "\n${GREEN}All required binaries are installed correctly.${NC}\n\n"
  else
    printf "\n"

    if [[ ! -z ${FAILED_INSTALL} ]] ; then
      printf "${RED}The following required binaries are not installed:${NC}\n"
      printf "${RED}${FAILED_INSTALL}${NC}\n"
    fi

    if [[ ! -z ${FAILED_VERSION} ]] ; then
      printf "${YELLOW}The following required binaries are using the wrong version:${NC}\n"
      printf "${YELLOW}${FAILED_VERSION}${NC}\n"
    fi

    exit 1
  fi

  printf "*********************************\n\n"
}

# Add 'n' number of binaries as per your project requirement
get_binary_version(){
  case ${1} in
    docker)
       docker version | tail -n +2 | head -1 | xargs echo -n | awk '{print $2}'
      ;;
    ansible)
      ansible --version | head -1 | awk '{print $2}'
      ;;
    packer)
      packer --version
      ;;
    terraform)
      terraform --version | head -1 | awk '{print $2}' | cut -d \v -f2
      ;;
    vault)
      vault --version | awk '{print $2}'
      ;;
    gcloud)
      gcloud --version | head -1 | awk '{print $4}'
      ;;
    jq)
      jq --version | cut -d \- -f2
      ;;
    kubectl)
      kubectl version --short=true | head -1 | awk '{print $3}' | cut -d \v -f2
      ;;
    *)
      echo ""
      ;;
  esac
}

check_required_binaries
