#!/bin/bash
set -e
if ! [ -f /usr/local/bin/ansible ]; then
    echo INFO Install ansible
    pip3 install ansible ansible-lint shellcheck -i https://pypi.mirrors.ustc.edu.cn/simple/ 
    ansible-galaxy collection install community.general
fi
read -rp "Please input your server ip add: " server_ip
read -rp "Please input your server sshd port: " sshd_port
if ping -c 3 "$server_ip"; then
    cat << EOF | tee inventory/selfhost
[selfhost]
myserver ansible_port="$sshd_port" ansible_host="$server_ip" ansible_python_interpreter=/usr/bin/python3
EOF
fi
echo INFO set up env
ansible-playbook -vvv plays/env.yml
echo INFO set up soft
read -rp "Do you want to install soft? yes or no: " _YoN
case "$_YoN" in
    yes | y | Y | YES)
        # ansible-playbook plays/soft.yml
        ;;
    *) ;;

esac
