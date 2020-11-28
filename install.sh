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
  echo "You must provide a project name." 1>&2
  exit 101
else
  PROJECT=$1
fi

if [ -z "$2" ]
then
  echo "You must provide a sudo password." 1>&2
  exit 101
else
  SUDO_PASS=$1
fi

VAGRANT_SHELL=${PROJECT}

if [ ! -d ${VAGRANT_SHELL} ]
then
  git clone --depth=1 https://github.com/kedwards/vagrant-shell.git ${VAGRANT_SHELL} && \
  rm -rf ${VAGRANT_SHELL}/.git\*
fi
