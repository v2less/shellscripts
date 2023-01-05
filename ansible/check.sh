#!/bin/bash
set -x
file=$1
list="donotexist.list"
touch "$list"
while read -r line;do
  name=$(echo $line|awk '{print $1}')
  if ! apt policy $name; then
     cat <<EOF | tee -a ${list}
$line
EOF
  fi
done < $file
