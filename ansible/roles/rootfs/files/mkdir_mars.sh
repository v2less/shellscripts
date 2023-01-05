#!/bin/bash

if [ ! -d /usr/share/debootstrap/scripts/mars ]; then
    rm -v /usr/share/debootstrap/scripts/mars
    mkdir -pv /usr/share/debootstrap/scripts/mars
fi
