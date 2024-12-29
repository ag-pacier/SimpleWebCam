#!/bin/bash
# This is a script to automate the initial setup of a raspberry pi webcam
# this will assume a fresh install of rasbian lite

echo "Updating OS and installing nginx with rtmp support and auto updates"
apt update > /dev/null
apt dist-upgrade -y > /dev/null
apt install libnginx-mod-rtmp nginx nginx-common gzip unattended-upgrades -y > /dev/null

cat >>/etc/apt/apt.conf.d/50unattended-upgrades <<EOL
Unattended-Upgrade::Origins-Pattern {
        "origin=Debian,codename=${distro_codename}-updates";
        "origin=Debian,codename=${distro_codename},label=Debian";
        "origin=Debian,codename=${distro_codename},label=Debian-Security";
        "origin=Raspbian,codename=${distro_codename},label=Raspbian";
        "origin=Raspberry Pi Foundation,codename=${distro_codename},label=Raspberry Pi Foundation";
};
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot-Time "02:00";
EOL

echo "Installed and configured unattended-upgrades"

cat >/etc/nginx/rtmp.conf <<EOL
rtmp {
  server {
    listen 1935;
    chunk_size 4096;
    allow publish 127.0.0.1;
    deny publish all;
    application live {
      live on;
      record off;
    }
  }
}
EOL

sed -e '/include /etc/nginx/modules-enabled/*.conf;/a\'$'\n''include /etc/nginx/rtmp.conf;' /etc/nginx/nginx.conf

echo "Activated RTMP on port 1935 for nginx."

cat >/etc/nginx/sites-available/rtmp <<EOL
server {
    listen 8080;
    server_name  localhost;

    # rtmp stat
    location /stat {
        rtmp_stat all;
        rtmp_stat_stylesheet stat.xsl;
    }
    location /stat.xsl {
        root /var/www/html/rtmp;
    }

    # rtmp control
    location /control {
        rtmp_control all;
    }
}
EOL

mkdir /var/www/html/rtmp
gunzip -c /usr/share/doc/libnginx-mod-rtmp/examples/stat.xsl.gz > /var/www/html/rtmp/stat.xsl
ln -s /etc/nginx/sites-available/rtmp /etc/nginx/sites-enabled/rtmp

systemctl reload nginx

echo "Activated RTMP stats on :8080/stat"

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

sed "0/POC Camera/s//$cam_name/" $script_loc
sed "0/label.txt/s//$label_loc/" $script_loc
sed "0/logo.png/s//$logo_loc/" $script_loc

systemctl enable webstream

echo "Setup complete. Please reboot and check the status of the stream."