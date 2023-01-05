#!/bin/bash
#shellcheck disable=SC2237
out() { printf "%s %s\\n%s\\n" "$1" "$2" "${@:3}"; }
error() { out "==> ERROR:" "$@"; } >&2
sudo apt install -y -q python3-pip jq dnsutils
pip3 install -i https://mirrors.aliyun.com/pypi/simple/ shyaml
sudo pip3 install -i https://mirrors.aliyun.com/pypi/simple/ shyaml
config_file=${1:-./edition/fs_cloudos.yml}
if ! [ -f "$config_file" ]; then
    error "No configuration file"
    exit 1
fi
cp -f "$config_file" ./edition/main.yml
read -ra nullvars <<< "$(shyaml get-value < ./edition/main.yml | grep null | awk '{print $1}' | tr '\n' ' ')"
for nullvar in "${nullvars[@]}"; do
    sed -ri "/$nullvar/d" edition/main.yml
done
