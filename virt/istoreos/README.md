## 安装 libvirt 和 qemu-kvm（Debian 或 Ubuntu）：
```bash
sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils sshpass
sudo systemctl is-active libvirtd | grep active || echo "libvirtd not running, is it correctly installed?"
sudo usermod -aG libvirt $USER
sudo usermod -aG kvm $USER
sudo systemctl restart libvirtd.service
sudo virsh net-autostart default

cat <<EOF | sudo tee /etc/polkit-1/localauthority/50-local.d/50-libvirt-remote-access.pkla
[Libvirt Management Access]
Identity=unix-group:libvirt
Action=org.libvirt.unix.manage
ResultAny=yes
ResultInactive=yes
ResultActive=yes
EOF
sudo systemctl restart polkit
virsh -c qemu:///system list --all
export LIBVIRT_DEFAULT_URI='qemu:///system'
```
## 下载istoreos
```bash
wget https://fw0.koolcenter.com/iStoreOS/x86_64/istoreos-22.03.6-2024031514-x86-64-squashfs-combined.img.gz
gunzip -k istoreos-22.03.6-2024031514-x86-64-squashfs-combined.img.gz
qemu-img convert -f raw -O qcow2 istoreos-22.03.6-2024031514-x86-64-squashfs-combined.img.gz istoreos.qcow2
qemu-img resize istoreos.qcow2 20G
sed -i "s# file='.*/istoreos.qcow2'# file='`pwd`/istoreos.qcow2'#" istoreos.xml
```
## 导入istoreos
```bash
virsh define istoreos.xml
```
## 启动istoreos
```bash
virsh start istoreos
```
## 安装服务器管理软件
```bash
sudo apt install cockpit cockpit-machines
sudo systemctl enable cockpit.socket --now
#默认端口9090
```
