#!/bin/bash -eux

apt-get -qq -y install python-software-properties
add-apt-repository -y ppa:chris-lea/node.js
apt-get -qq -y install nodejs
