#!/bin/bash

function get_latest_release() {
    curl --silent "https://api.github.com/repos/$1/releases/latest" | grep -Po '"tag_name":[ ]*"\K.*?(?=")'
}

install_node_exporter() {
    ARCH=$(uname -m)
    case $ARCH in
        x86_64)
            arch=amd64
            ;;
        aarch64)
            arch=arm
            ;;
        mips64)
            arch=mips64el
            ;;
        *) ;;
    esac
    while [ -z "$node_version" ]; do
        node_version=$(get_latest_release "prometheus/node_exporter")
    done
    wget https://github.com/prometheus/node_exporter/releases/download/"$node_version"/node_exporter-"${node_version##*v}".linux-"$arch".tar.gz
    sleep 1
    tar -xzf node_exporter-"${node_version##*v}".linux-"$arch".tar.gz
    cd node_exporter-"${node_version##*v}".linux-"$arch" || exit 1
    sudo mv node_exporter /usr/local/bin/
    sudo useradd -rs /bin/false node_exporter
    cat <<EOF | sudo tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF
  sudo systemctl daemon-reload
  sudo systemctl start node_exporter
  sudo systemctl enable node_exporter
}
install_node_exporter

