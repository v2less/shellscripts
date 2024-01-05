#!/bin/bash
# setup vsftp for repo.
package() {
    packages=("$@")
    apt=$(command -v apt-get)
    yum=$(command -v yum)
    yay=$(command -v yay)
    if [ -z "$yay" ]; then
        pacman=$(command -v pacman)
    fi
    if [ -n "$apt" ]; then
        sudo apt-get update
        sudo apt-get -y install "${packages[@]}"
    elif [ -n "$yum" ]; then
        sudo yum -y install "${packages[@]}"
    elif [ -n "$yay" ]; then
        yay -S "${packages[@]}"
    elif [ -n "$pacman" ]; then
        sudo pacman -S "${packages[@]}"
    else
        echo "Err: no path to apt-get or yum" >&2
    fi
}
vsftp_anon(){
sudo sed -ri '/anonymous_enable/d' /etc/vsftpd.conf &> /dev/null
sudo sed -ri '/no_anon_password/d' /etc/vsftpd.conf &> /dev/null
sudo sed -ri '/anon_root/d' /etc/vsftpd.conf &> /dev/null
sudo sed -ri "/listen_ipv6/aanonymous_enable=YES\nno_anon_password=YES\nanon_root=/srv/ftp/" /etc/vsftpd.conf &> /dev/null
sudo sed -ri '/utf8_filesystem/cutf8_filesystem=YES' /etc/vsftpd.conf &> /dev/null
sudo systemctl restart vsftpd.service
}

if ! vsftpdwho &> /dev/null; then
    package vsftpd
fi
vsftp_anon
