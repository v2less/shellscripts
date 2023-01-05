#!/bin/bash
verlte() {
    printf '%s\n%s' "$1" "$2" | sort -C -V
}
verlte $1 $2 && echo "$1 小于等于 $2" || echo "$1 大于 $2"
