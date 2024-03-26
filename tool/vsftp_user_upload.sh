#!/bin/bash
# setup vsftp for repo.
# by user <user@uniontech.com> 2020-11-18
set -x
function package() {
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

if ! vsftpdwho &> /dev/null; then
        package vsftpd
fi
ftp_only(){
    cat <<EOF | sudo tee /bin/ftponly
#!/bin/sh
echo "This account is limited to FTP access only."
EOF
    sudo chmod a+x /bin/ftponly
    echo "/bin/ftponly" | sudo tee -a /etc/shells
}
vsftp_user(){
local USER=$1
sudo useradd -m -s /bin/ftponly "$USER"
sudo mkdir -p /home/"$USER"/ftp/upload
sudo chown -R nobody:nogroup /home/"$USER"/ftp
sudo chmod a+rwx /home/"$USER"/ftp/upload
sudo sed -ri '/anonymous_enable/d' /etc/vsftpd.conf &> /dev/null
sudo sed -ri '/no_anon_password/d' /etc/vsftpd.conf &> /dev/null
sudo sed -ri '/write_enable/d' /etc/vsftpd.conf &> /dev/null
sudo sed -ri '/anon_upload_enable/d' /etc/vsftpd.conf &> /dev/null
sudo sed -ri '/anon_mkdir_write_enable/d' /etc/vsftpd.conf &> /dev/null
sudo sed -ri '/anon_umask/d' /etc/vsftpd.conf &> /dev/null
sudo sed -ri '/anon_root/d' /etc/vsftpd.conf &> /dev/null
sudo sed -ri '/anon_other_write_enable/d' /etc/vsftpd.conf &> /dev/null
sudo sed -ri '/chroot_local_user/d' /etc/vsftpd.conf &> /dev/null
sudo sed -ri '/user_sub_token/d' /etc/vsftpd.conf &> /dev/null
sudo sed -ri '/local_root/d' /etc/vsftpd.conf &> /dev/null
sudo sed -ri '/local_enable/d' /etc/vsftpd.conf &> /dev/null
sudo sed -ri '/local_umask/d' /etc/vsftpd.conf &> /dev/null
sudo sed -ri '/userlist_enable/d' /etc/vsftpd.conf &> /dev/null
sudo sed -ri '/userlist_file/d' /etc/vsftpd.conf &> /dev/null
sudo sed -ri '/userlist_deny/d' /etc/vsftpd.conf &> /dev/null
sudo sed -ri '/hide_file/d' /etc/vsftpd.conf &> /dev/null
sudo sed -ri "/listen_ipv6/aanonymous_enable=NO\nwrite_enable=YES\nlocal_enable=YES\nlocal_umask=022\nchroot_local_user=YES\nuser_sub_token=$USER\nlocal_root=/home/$USER/ftp\nuserlist_enable=YES\nuserlist_file=/etc/vsftpd.userlist\nuserlist_deny=NO\nhide_file={secret,fancyindex,.hidden*}" /etc/vsftpd.conf &> /dev/null
sudo sed -ri '/utf8_filesystem/cutf8_filesystem=YES' /etc/vsftpd.conf &> /dev/null
echo "$USER" | sudo tee -a /etc/vsftpd.userlist
sudo systemctl restart vsftpd.service
}
ftp_only
vsftp_user "$1"
