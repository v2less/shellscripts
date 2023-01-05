#!/bin/bash

domain_name=${1:-abc.v2less.com}
username="helloworld"
password=$(cat /dev/urandom | tr -dc a-zA-Z0-9 | head -c32)
install_go() {
  wget https://go.dev/dl/go1.19.linux-amd64.tar.gz
  tar -zxvf go1.19.linux-amd64.tar.gz -C /usr/local/
  echo export PATH=$PATH:/usr/local/go/bin  >> /etc/profile
  source /etc/profile
  go version
}
install_caddy() {
go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest
~/go/bin/xcaddy build --with github.com/caddyserver/forwardproxy@caddy2=github.com/klzgrad/forwardproxy@naive
cp caddy /usr/bin/
/usr/bin/caddy version
setcap cap_net_bind_service=+ep /usr/bin/caddy
}
set_bbr() {
bash -c 'echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf'
bash -c 'echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf'
sysctl -p
}

install_acme() {
curl https://get.acme.sh | sh -s email=waytoarcher@gmail.com
}
install_cert() {
acme.sh --installcert -d ${domain_name} --fullchainpath /data/${domain_name}.crt --keypath /data/${domain_name}.key --ecc --force
}
gen_cert() {
apt install -y socat
mkdir -p /data
acme.sh --issue --standalone -d ${domain_name} -k ec-256 --force
install_cert
}
renew_cert() {
acme.sh --renew -d abc.v2less.com
install_cert
}
set_caddy() {
mkdir /etc/caddy
cat <<EOF |tee /etc/caddy/Caddyfile
:443, ${domain_name}
tls /data/${domain_name}.crt /data/${domain_name}.key
route {
  forward_proxy {
    basic_auth ${username} ${password}
    hide_ip
    hide_via
    probe_resistance
  }
    reverse_proxy https://bing.com {
    header_up Host {upstream_hostport}
  }
}
EOF
caddy fmt --overwrite /etc/caddy/Caddyfile
#caddy run --config /etc/caddy/Caddyfile
cat <<EOF | tee /etc/systemd/system/naive.service
[Unit]
Description=Caddy
Documentation=https://caddyserver.com/docs/
After=network.target network-online.target
Requires=network-online.target
[Service]
Type=notify
User=root
Group=root
ExecStart=/usr/bin/caddy run --environ --config /etc/caddy/Caddyfile
ExecReload=/usr/bin/caddy reload --config /etc/caddy/Caddyfile
TimeoutStopSec=5s
LimitNOFILE=1048576
LimitNPROC=512
PrivateTmp=true
ProtectSystem=full
AmbientCapabilities=CAP_NET_BIND_SERVICE
[Install]
WantedBy=multi-user.target
EOF
#daemon-reload 加载新的 unit 配置文件
systemctl daemon-reload
#enable 创建 unit 配置文件的软链
systemctl enable naive
#start 启动配置文件
systemctl start naive
#status 查看配置文件当前状态
systemctl status naive
ss -tulpn | grep caddy
}
gen_client() {
cat <<EOF | tee client.json
{
  "listen": "socks://127.0.0.1:1080",
  "proxy": "https://${username}:${password}@${domain_name}",
  "log": ""
}
EOF
}
