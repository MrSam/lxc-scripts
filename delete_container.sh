#!/bin/bash

set -e

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Script needs to be run as root";
    exit 1;
fi

if [ $# -ne 1 ]; then
  echo "Usage: $0 <container-name>"
  exit 1;
fi
name=$1

if [[ ! -d /var/lib/lxc/$name/ ]]; then
  echo "Container named $name does not exists."
  exit 1;
fi

lxc-stop --name $name
lxc-destroy --name $name
rm /etc/nginx/conf.d/$name.$DOMAIN_SUFFIX.conf
service nginx restart
