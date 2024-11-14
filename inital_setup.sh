#!/bin/bash
# This is a script to automate the initial setup of a raspberry pi webcam
# this will assume a fresh install of rasbian lite

echo "Updating OS and installing nginx with rtmp support"
apt update > /dev/null
apt dist-upgrade -y > /dev/null
apt install libnginx-mod-rtmp -y > /dev/null

read -p "What should be the camera name?(default is NewCam)" webcam_name

if ${#webcam_name} -lt 3
then webcam_name="NewCam"
fi

echo "Using $webcam_name for the device name."
echo "export WEBCAM_NAME=$webcam_name" >> /etc/profile

cat >/etc/nginx/rtmp.conf <<EOL
rtmp {
  server {
    listen 1935;
    chunk_size 4096;
    application live {
      live on;
      record off;
    }
  }
}
EOL

sed -e '/include /etc/nginx/modules-enabled/*.conf;/a\'$'\n''include /etc/nginx/rtmp.conf;' /etc/nginx/nginx.conf