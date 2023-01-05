#!/bin/bash -x
set -exo pipefail
# 让 privoxy 代理服务器使用 gfwlist 自动分流
# 请修改为可用的http代理
http_proxy_ip="proxy02.xxxx.com"
http_proxy_port="3128"
sudo apt install -y privoxy python3-pip proxychains
sudo sed -ri '/^socks.*$/d' /etc/proxychains.conf
sudo sed -ri '/^http.*$/d' /etc/proxychains.conf
echo "http 127.0.0.1 8118" | sudo tee -a /etc/proxychains.conf

# 修改 privoxy 配置，默认使用 8118 本地端口
grep -P '^listen-address\s+\d' /etc/privoxy/config || echo 'listen-address  0.0.0.0:8118' | sudo tee -a /etc/privoxy/config
sudo sed -ri "/$http_proxy_ip:$http_proxy_port/d" /etc/privoxy/config
cd /tmp || exit
# 用户规则
cat  <<EOF | tee user.rule
.ajax.cloudflare.com
.amazonaws.com
.apkmirror.com
.bitbucket.com
.blogspot.tw
.cc
.cefamilie.com
.contentabc.com
.ecchi.iwara.tv
.frantech.ca
.github.io
.githubassets.com
.githubusercontent.com
.jimpop.org
.me
.phncdn.com
.pw
.python.org
.sosreader.com
.teamviewer.com
.tellapart.com
.webupd8.org
.yubico.com
EOF

## 生成 gfwlist.action
export proxy=http://$http_proxy_ip:$http_proxy_port
export http_proxy=$proxy
export https_proxy=$proxy
python3 -m pip install pip --upgrade
python3 -m pip install gfwlist2privoxy
wget -O gfwlist.txt https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt
gfwlist2privoxy -i gfwlist.txt -f gfwlist.action --user-rule user.rule -p $http_proxy_ip:$http_proxy_port -t http
[ -f gfwlist.action ] || exit 1
# 追加部分地址到user.action
[ -f gfwlist.action ] && cat << EOF | tee direct.action
{+forward-override{forward .}}
.baidu.com
.qq.com
127.*.*.*
192.*.*.*
10.*.*.*
localhost
::1
EOF
sudo mv -f gfwlist.action /etc/privoxy/
sudo mv -f direct.action /etc/privoxy/
grep -q "gfwlist\.action" /etc/privoxy/config || echo 'actionsfile gfwlist.action' | sudo tee -a /etc/privoxy/config
grep -q "direct\.action" /etc/privoxy/config || echo 'actionsfile direct.action' | sudo tee -a /etc/privoxy/config
# 生成 gfwlist.action 后刷新 privoxy
sudo service privoxy force-reload
# 如何使用代理
echo "use http_proxy method:"
echo "
proxy='http://127.0.0.1:8118'
export http_proxy=\$proxy
export https_proxy=\$proxy
"
echo "Or use proxychains method"
echo "exec proxychains -q bash"
