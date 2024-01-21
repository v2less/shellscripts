#!/bin/bash

case $(uname -m) in
    x86_64)
        docker build --network=host --build-arg http_proxy=http://192.168.137.1:7890 --build-arg https_proxy=http://192.168.137.1:7890 -t ide .
        ;;
        #docker build . -t ide ;;
    arm64)  docker build -f Dockerfile.arm . -t ide ;;
esac
