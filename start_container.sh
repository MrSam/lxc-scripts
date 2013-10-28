#!/bin/bash

LXC_TEMPLATE_NAME="lamp_template"
DOMAIN_SUFFIX="cloud.mujo.be"

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
## start the lxc container
echo "Starting the container: $name" 
lxc-start -n $name -d

newIP=`lxc-ls --active --fancy | grep $name | awk -F " " '{print $3}'`
#keep trying
         while [  "$newIP" == "-" ]; do
	     sleep 2s
             newIP=`lxc-ls --active --fancy | grep $name | awk -F " " '{print $3}'` 
         done

## set up Nginx reverse proxying
cat > /etc/nginx/conf.d/$name.$DOMAIN_SUFFIX.conf <<EOF
server {
    listen 80;
    server_name $name.$DOMAIN_SUFFIX;

    access_log /var/log/nginx/$name.access.log;
    error_log /var/log/nginx/$name.error.log;

    location / {
        proxy_pass_header Server;
        proxy_set_header Host \$http_host;
        proxy_redirect off;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Scheme \$scheme;
        proxy_connect_timeout 3;
        proxy_read_timeout 10;
        proxy_pass http://$newIP:80/;
    }
}
EOF

service nginx restart

echo "Container $name started."
echo -e "\tInternal IP:\t\t $newIP"
echo -e "\tPROXY:\t\t http://$name.$DOMAIN_SUFFIX"
