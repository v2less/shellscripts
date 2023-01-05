#!/bin/bash
set -e

if [ $# -ne 1 ]; then
	echo "Usage: $0 domain_name" >&2
	exit 1
fi

do_name=$1

apt-get update && apt-get -y upgrade
apt-get -y install nginx socat
hostnamectl set-hostname "$do_name"
bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
curl https://get.acme.sh | sh
systemctl stop nginx
~/.acme.sh/acme.sh --issue -d "$do_name" --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d "$do_name" --fullchainpath /etc/v2ray/v2ray.crt --keypath /etc/v2ray/v2ray.key --ecc
cat <<EOF >>/etc/nginx/sites-available/ssl
server {
    listen 443 ssl default_server;
    listen [::]:443 ssl default_server;
    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;
    ssl on;
    ssl_certificate       /etc/v2ray/v2ray.crt;
    ssl_certificate_key   /etc/v2ray/v2ray.key;
    ssl_protocols         TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers           HIGH:!aNULL:!MD5;
    server_name           $do_name;

    location /c58640f/ {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:35265;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF
ln -sf /etc/nginx/sites-available/ssl /etc/nginx/sites-enabled/
rm -f /etc/v2ray/config.json
cat <<EOF | tee /etc/v2ray/config.json
{
  "log": {
    "access": "/var/log/v2ray/access.log",
    "error": "/var/log/v2ray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "port": 35265,
      "listen":"127.0.0.1",
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "a0836f20-4154-28c1-c7c0-d49e7242b9f2",
            "alterId": 64,
            "security": "auto",
            "level": 0
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/c58640f/"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
EOF

systemctl restart nginx
systemctl enable nginx
systemctl restart v2ray
systemctl enable v2ray

netstat -lntp
echo "done, enjoy!"
