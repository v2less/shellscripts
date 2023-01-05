#!/bin/bash
list=$1
while read -r line; do
  curl -k -F "file=@$line" -F "token=etllhqgeg0dgrhpevx99" -F "model=2"  -X POST "https://connect.tmp.link/api_v2/cli_uploader"
done < "$list"
