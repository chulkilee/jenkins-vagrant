#!/bin/bash -eux

apt-get -qq update
apt-get -qq -y install \
    curl git subversion vim
