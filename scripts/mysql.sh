#!/bin/bash -eux

# Set empty password for mysql root
export DEBIAN_FRONTEND=noninteractive
echo mysql-server-5.5 mysql-server/root_password password '' | debconf-set-selections
echo mysql-server-5.5 mysql-server/root_password_again password '' | debconf-set-selections

# Install packages
apt-get install -qq -y \
    mysql-server-5.5 \
    mysql-client-5.5 \
    libmysqlclient18 \
    libmysqlclient-dev
