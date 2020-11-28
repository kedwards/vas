#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if (( EUID != 0 ))
then
  echo "You must be root to run this file." 1>&2
  exit 100
fi

if [ -z "$1" ]
then
  echo "You must provide a project path." 1>&2
  exit 101
else
  PROJECT_PATH=$1
fi

if [ ! -d ${PROJECT_PATH} ]
then
  git clone --depth=1 https://github.com/kedwards/vagrant-shell.git ${PROJECT_PATH} && \
  rm -rf ${PROJECT_PATH}/.git\*
fi
