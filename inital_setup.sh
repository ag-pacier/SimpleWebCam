#!/bin/bash
# This is a script to automate the initial setup of a raspberry pi webcam
# this will assume a fresh install of rasbian lite

echo "Updating OS and installing nginx with rtmp support"
apt update > /dev/null
apt dist-upgrade -y > /dev/null
apt install libnginx-mod-rtmp -y > /dev/null

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
systemctl daemon-reload
systemctl restart nginx

echo "Activated RTMP on port 1935."

read -p "Where is the webrun.sh script going to live? Please use the full path" script_loc

cat >/etc/systemd/system/webstream.service <<EOL
[Unit]
Description=Streamer
After=network.target

[Service]
ExecStart=$script_loc
KillMode=control-group
Restart=on-failure
TimeoutSec=2

[Install]
WantedBy=multi-user.target
Alias=streaming.service
EOL

read -p "What is the name of the camera?" cam_name

read -p "Where is the label going to live?" label_loc

read -p "Where is the logo going to live?" logo_loc

sed s/"POC Camera"/$cam_name $script_loc
sed s/"label.txt"/$label_loc $script_loc
sed s/"logo.png"/$logo_loc $script_loc

systemctl enable webstream

echo "Setup complete. Please reboot and check the status of the stream."