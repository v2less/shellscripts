#! /bin/bash
set -eu
for _play in plays/*.yml; do
    ansible-playbook --syntax-check "${_play}"
    ansible-lint "${_play}"
done
find . -name '*.sh' \! -name 'modinfo.sh' -exec shellcheck -s bash '{}' \;
