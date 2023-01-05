#!/bin/bash
function get_latest_release() {
    curl --silent "https://api.github.com/repos/$1/releases/latest" | grep -Po '"tag_name":[ ]*"\K.*?(?=")'
}

install_prometheus() {
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
    while [ -z "$prom_version" ]; do
        prom_version=$(get_latest_release "prometheus/prometheus")
    done
    wget https://github.com/prometheus/prometheus/releases/download/"$prom_version"/prometheus-"${prom_version##*v}".linux-"$arch".tar.gz
    sleep 1
    tar -xzf prometheus-"${prom_version##*v}".linux-"$arch".tar.gz
    cd prometheus-"${prom_version##*v}".linux-"$arch" || exit 1
    mkdir -p data
}
install_prometheus
