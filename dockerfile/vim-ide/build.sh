#!/bin/bash

case $(uname -m) in
    x86_64)
        docker build --net=host --build-arg http_proxy=http://0.0.0.0:7890 --build-arg https_proxy=http://0.0.0.0:7890 -t ide .
        ;;
        #docker build . -t ide ;;
    arm64)  docker build -f Dockerfile.arm . -t ide ;;
esac
