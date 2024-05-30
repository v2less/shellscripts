#!/usr/bin/env bash
#shellcheck disable=SC1091
# 定义颜色输出函数
red() { echo -e "\033[31m\033[01m[WARNING] $1\033[0m"; }
green() { echo -e "\033[32m\033[01m[INFO] $1\033[0m"; }
greenline() { echo -e "\033[32m\033[01m $1\033[0m"; }
yellow() { echo -e "\033[33m\033[01m[NOTICE] $1\033[0m"; }
blue() { echo -e "\033[34m\033[01m[MESSAGE] $1\033[0m"; }
light_magenta() { echo -e "\033[95m\033[01m[NOTICE] $1\033[0m"; }
highlight() { echo -e "\033[32m\033[01m$1\033[0m"; }
cyan() { echo -e "\033[38;2;0;255;255m$1\033[0m"; }

declare -a menu_options
declare -A commands
codename=$(lsb_release -cs | tail -1)
distro=$(lsb_release -is | tail -1 tr '[:upper:]' '[:lower:]')
# 检查是否以 root 用户身份运行
if [ "$(id -u)" -eq 0 ]; then
    echo "此脚本需要以普通用户权限运行"
    exit 1
fi
menu_options=(
    "更换较快apt软件源"
    "更新系统软件包"
    "安装常用软件包"
    "安装项目构建用的docker环境"
    "挂载90的代码镜像samba服务到本地"
    "配置git提交模板"
    "安装VSCode"
    "安装PyCharm"
    "安装命令行类代理工具"
    "安装SVN"
    "安装谷歌浏览器"
    "单独安装docker"
    "单独配置docker镜像"
    "安装静态检查工具"
    "配置Jenkins构建节点环境"
    "更新脚本"
)

commands=(
      ["更换较快apt软件源"]="use_local_apt_mirror"
      ["更新系统软件包"]="update_system_packages"
      ["安装常用软件包"]="install_common_soft"
      ["安装项目构建用的docker环境"]="install_docker_for_build"
      ["挂载90的代码镜像samba服务到本地"]="mount_90_mirror_samba"
      ["配置git提交模板"]="config_git_commit_template"
      ["安装VSCode"]="install_vscode"
      ["安装PyCharm"]="install_pycharm"
      ["安装命令行类代理工具"]="install_proxytool"
      ["安装SVN"]="install_svn"
      ["安装谷歌浏览器"]="install_chrome"
      ["单独安装docker"]="install_docker"
      ["单独配置docker镜像"]="config_docker"
      ["安装静态检查工具"]="install_check_and_format"
      ["配置Jenkins构建节点环境"]="setup_build_node"
      ["更新脚本"]="update_scripts"
)
update_scripts() {
    wget -O pi.sh https://cafe.cpolar.cn/wkdaily/zero3/raw/branch/main/zero3/pi.sh && chmod +x pi.sh
    echo "脚本已更新并保存在当前目录 pi.sh,现在将执行新脚本。"
    ./pi.sh
    exit 0
}
# 定义镜像列表
UBUNTU_MIRRORS=(
    "http://archive.ubuntu.com/ubuntu/"
    "http://mirrors.163.com/ubuntu/"
    "http://mirrors.aliyun.com/ubuntu/"
    "http://mirrors.ustc.edu.cn/ubuntu/"
    "http://mirrors.tuna.tsinghua.edu.cn/ubuntu/"
    "http://10.31.1.208/ubuntu/"
)
DEBIAN_MIRRORS=(
    "http://deb.debian.org/debian/"
    "http://mirrors.163.com/debian/"
    "http://mirrors.aliyun.com/debian/"
    "http://mirrors.ustc.edu.cn/debian/"
    "http://mirrors.tuna.tsinghua.edu.cn/debian/"
)

# 测试各个镜像的响应时间
get_fastest_mirror() {
    local -n arr=$1
    IFS=$'\n' read -r -d '' MIRRORS << EOF
$(printf "%s\n" "${arr[@]}")
EOF
    fastest_mirror=""
    fastest_time=999999
    for mirror in "${MIRRORS[@]}"; do
        echo "Testing $mirror"
        start_time=$(date +%s%N)
        if wget -q --spider --timeout=2 "$mirror"; then
            end_time=$(date +%s%N)
            response_time=$(((end_time - start_time) / 1000000))
            echo "$mirror responded in ${response_time}ms"
            if [ $response_time -lt $fastest_time ]; then
                fastest_time=$response_time
                fastest_mirror=$mirror
            fi
        else
            echo "$mirror did not respond."
        fi
    done

    if [ -z "$fastest_mirror" ]; then
        echo "No mirror responded."
        exit 1
    fi

    echo "Fastest mirror is $fastest_mirror with ${fastest_time}ms response time."
}
use_local_apt_mirror() {
    case $distro in
        ubuntu)
            get_fastest_mirror "${UBUNTU_MIRRORS[@]}"
            case $codename in
                nodle)
                    [[ -f /etc/apt/sources.list.d/ubuntu.sources.bak ]] || sudo cp /etc/apt/sources.list.d/ubuntu.sources{,.bak}
                    sudo sed -i "s;http.*/ubuntu/;$fastest_mirror;g" /etc/apt/sources.list.d/ubuntu.sources
                    ;;
                *)
                    [[ -f /etc/apt/sources.lit.bak ]] || sudo cp /etc/apt/sources.list{,.bak}
                    sudo sed -i "s;http.*/ubuntu/;$fastest_mirror;g" /etc/apt/sources.list
                    ;;
            esac
            ;;
        debian)
            get_fastest_mirror "${DEBIAN_MIRRORS[@]}"
            [[ -f /etc/apt/sources.lit.bak ]] || sudo cp /etc/apt/sources.list{,.bak}
            sudo sed -i "s;http.*/debian/;$fastest_mirror;g" /etc/apt/sources.list
            ;;
        *)  ;;
    esac
    sudo apt update
}
# 更新系统软件包
update_system_packages() {
    green "Setting timezone Asia/Shanghai..."
    sudo timedatectl set-timezone Asia/Shanghai
    # 更新系统软件包
    green "Updating system packages..."
    sudo apt update
    sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
    if ! command -v curl &> /dev/null; then
        red "curl is not installed. Installing now..."
        sudo apt install -y curl
        if command -v curl &> /dev/null; then
            green "curl has been installed successfully."
        else
            echo "Failed to install curl. Please check for errors."
        fi
    else
        echo "curl is already installed."
    fi
}
install_docker() {
    bash <(wget -q -O - https://get.docker.com) --mirror Aliyun
    if grep -q docker /etc/group; then
        :
    else
        sudo groupadd -g 999 docker
    fi
    if id "$USER" | grep -q docker; then
        :
    else
        sudo usermod -aG docker "$USER"
        sudo systemctl reload docker || true
        sleep 3
        echo "Please re-loggin again"
        exit 0
    fi
}
config_docker() {
    cat << EOF | sudo tee /etc/docker/daemon.json
{
  "registry-mirrors": [
    "http://f1361db2.m.daocloud.io",
    "https://registry.docker-cn.com",
    "http://hub-mirror.c.163.com",
    "http://10.31.1.205:5000",
    "http://10.31.1.205:5001"
  ],
  "insecure-registries": [ "10.31.1.205:5000", "10.31.1.205:5001" ],
  "log-driver":"json-file",
  "log-opts":{ "max-size" :"100m","max-file":"1"}
}
EOF
    sudo systemctl daemon-reload
    sudo systemctl reload docker.service
}
install_docker_for_build() {
    username="${1:-builder}"
    green "初始化docker环境"
    current_uid=$(id -u)
    if [[ '1002' == "$current_uid" ]]; then
        green "当前用户${USER}的id是1002，符合要求，跳过新建用户"
        username=$USER
    else
        if ! id -u "$username"; then
            green "新建用户$username"
            sudo useradd -m -s /bin/bash -u 1002 "$username"
            green "请设置用户${username}的密码："
            sudo passwd "$username"
        fi
        green "$username加入sudo用户组"
        sudo usermod -aG sudo "$username"
    fi

    green "设置$username免密使用sudo"
    cat << EOF | sudo tee /etc/sudoers.d/"$username"
$username ALL=(ALL:ALL) NOPASSWD:ALL
EOF

    green "安装Docker"
    curl -fsSL https://get.docker.com | sudo bash -s docker --mirror Aliyun
    green "添加${username}到docker用户组"
    sudo usermod -aG docker "$username"

    green "配置docker，使用内网docker服务器"
    sudo mkdir /etc/docker
    cat << EOF | sudo tee /etc/docker/daemon.json
{
  "registry-mirrors": [
    "http://f1361db2.m.daocloud.io",
    "https://registry.docker-cn.com",
    "http://hub-mirror.c.163.com"
    "http://10.31.1.205:5000",
    "http://10.31.1.205:5001"
  ],
  "insecure-registries": [ "10.31.1.205:5000", "10.31.1.205:5001" ],
  "live-restore": true
}
EOF

    sudo systemctl daemon-reload
    sudo systemctl restart docker

    green "使用${username}拉取docker镜像"
    sudo -u "$username" bash << EOF
mkdir \$HOME/.cache
docker pull 10.31.1.205:5000/builder18.04-ccache:latest
EOF
    green "请使用${username}登录系统并使用下面的命令启动容器进行构建"
    green "起总/data是你的代码所在目录，可以自行修改冒号前的/data"
    green "分配的内存和cpu，请根据你的实际情况进行修改"
    cat << EOF
cd /data
mkdir cache
docker run --privileged \
           --volume=./cache:/.cache \
           --volume=/etc/localtime:/etc/localtime:ro \
           --volume=/data:/data \
           --volume=/data-hdd:/data-hdd \
           --volume=/mnt:/mnt \
           --volume=$HOME/.ssh:/home/talos/.ssh \
           --memory=32G --cpus=16 -it --rm \
           10.31.1.205:5000/builder18.04-ccache:latest
EOF
}
function get_latest_release() {
    curl --silent "https://api.github.com/repos/$1/releases/latest" | grep -Po '"tag_name":[ ]*"\K.*?(?=")'
}
extract()  {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2) tar xvjf "$1" ;;
            *.tar.gz) tar xvzf "$1" ;;
            *.tar.xz) tar xvJf "$1" ;;
            *.bz2) bunzip2 "$1"     ;;
            *.rar) unrar x "$1"     ;;
            *.gz)  gunzip "$1"      ;;
            *.tar) tar xvf "$1"     ;;
            *.tbz2) tar xvjf "$1"   ;;
            *.tgz) tar xvzf "$1"    ;;
            *.zip) unzip "$1"       ;;
            *.Z)   uncompress "$1"  ;;
            *.7z)  7z x "$1"        ;;
            *.xz)  unxz "$1"        ;;
            *.exe) cabextract "$1"  ;;
            *)  printf "'%s': unrecognized file compression\n" "$1" ;;
        esac
    else
        printf "'%s'is not a valid file\n" "$1"
    fi
}
function install_common_soft() {
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y git git-review tree unzip build-essential curl wget aria2 python3-pip fakeroot manpages-zh debhelper htop
    sudo apt install -y devscripts pbuilder cmake neofetch jq screen universal-ctags
    if [ -n "$DISPLAY" ]; then
        sudo apt install -y firefox-esr keepassxc telegram-desktop mpv gnome-terminal mousepad xclip
    fi
}
config_git_commit_template() {
    cat << EOF | tee "$HOME"/.gitcommit_template
1模块[Feature|Bugfix]:xxx

3xxx

ST-result:NA|PASS

Bugid:

Associated Branch Path:
   xxx

#Change-Id:git commit后自动生成

#第一行: 模块[Feature|Bugfix]: 标题
#模块:Audio, Camera, Wifi, WallPaper, AMS, PMS,PKMS, IMS, Input, TP, LCM, Sensor, Chager, 手写笔, 功耗, 稳定性，性能，安全，云知声, 后门, 大盘-功耗, 大盘-稳定性，大盘-性能，大盘-安全, OTA, Drop-BugRe, ...
#[Feature]:提交为需求的标识; [Bugﬁx]:代码缺陷修改。
#标题:如果1个feature或bugﬁx有多笔(git仓)的提交，每笔后面带标号，如带(1/4), (2/4) ...

#第三行:代表具体出现问题的原因或者feature的概括描述,可写多行

#ST-result：NA or PASS //代表静态代码分析和自测结果

#Bugid://具体的bug对应的Id或需求Id

#Associated Branch Path://相关分支路径,如：
#     alps/device/mediateksample/tbxxx_wifi/
#     alps/kernel-4.19/

#Signed-off-by:提交时git commit -s自动生成
EOF
    git config --global commit.template ~/.gitcommit_template
    git config --global gitreview.remote origin
}
function install_pycharm() {
    latest_version=$(wget -O - "https://data.services.jetbrains.com/products/releases?code=PCP&latest=true&type=release" 2> /dev/null | jq -r '.PCP[]|.version')

    cd /tmp || exit
    rm -rf pycharm-community-"$latest_version"* || true
    wget https://download.jetbrains.com/python/pycharm-community-"$latest_version".tar.gz
    sleep 3
    tar -xf pycharm-community-"$latest_version".tar.gz || exit
    echo copy to /opt/
    sudo cp -rf pycharm-community-"$latest_version" /opt/
    echo remove download files
    rm -rf pycharm-community-"$latest_version"* || true
    cd /opt/pycharm-community-"$latest_version"/bin || exit
    sleep 3
    echo setup pycharm
    sudo sed -r '/^SED/aexport _JAVA_AWT_WM_NONREPARENTING=1' ./pycharm.sh
    cat << EOF | sudo tee /etc/sysctl.d/notify.conf
fs.inotify.max_user_watches = 524288
EOF

    cat << EOF | sudo tee /usr/bin/pycharm
#! /usr/bin/bash
nohup /usr/lib/gnome-settings-daemon/gsd-xsettings > /dev/null 2>&1 &
export _JAVA_AWT_WM_NONREPARENTING=1
/opt/pycharm-community-"$latest_version"/bin/pycharm.sh
EOF

    sudo chmod a+x /usr/bin/pycharm
    sudo sysctl -p --system
    ./pycharm.sh
}
function uninstall_pycharm() {
    latest_version=$(wget -O - "https://data.services.jetbrains.com/products/releases?code=PCP&latest=true&type=release" 2> /dev/null | jq -r '.PCP[]|.version')
    rm -rf "$HOME"/.config/JetBrains
    rm -rf "$HOME"/.java
    rm -rf "$HOME"/.jetbrains
    sudo rm -rf /opt/pycharm-community-"$latest_version"
    sudo rm -rf /usr/local/bin/charm
}
function pycharm() {
    echo "
1. install pycharm
2. uninstall pycharm
3. exit
"
    read -r ipx
    case $ipx in
        1)
            install_pycharm
            echo "pycharm plugins: shell script, save, ansible and so on."
            ;;
        2)
            uninstall_pycharm
            ;;
        3)
            exit
            ;;
        *) ;;
    esac
}
function install_vscode() {
    wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
    sudo apt update
    sudo apt install code -y
}
# kvm
function install_kvm_less() {
    TUSER="$USER"
    sudo apt install -y qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virt-manager
    sudo usermod -aG libvirt "$TUSER"
    sudo usermod -aG kvm "$TUSER"
    sudo virsh net-autostart default
    sudo virsh net-start default
}
function install_kvm_more() {
    TUSER="$USER"
    echo "Virtualization host installation"
    sudo apt install -y libvirt-dev virt-viewer uuid-runtime
    sudo apt install -y pkg-config genisoimage netcat
    sudo apt install -y kpartx qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virtinst virt-manager qemu-system-arm qemu-utils qemu-user-static
    sudo apt install -y qemu-efi qemu-efi-aarch64 qemu-efi-arm qemu python-libvirt uml-utilities qemu-system gcc-arm-linux-gnueabihf libc6-dev-armhf-cross
    sudo apt install -y virt-top libguestfs-tools libosinfo-bin libvirt-daemon
    sudo usermod -aG libvirt "$TUSER"
    sudo usermod -aG kvm "$TUSER"
    sudo systemctl restart libvirtd.service
}
# pcmanfm
function install_pcmanfm() {
    sudo apt install -y pcmanfm exo-utils libexo-1-0
    if [ -f /usr/share/dbus-1/services/com.deepin.filemanager.filedialog.service ]; then
        sudo sed -ri 's/^[ \t*#*]Exec/#&/' /usr/share/dbus-1/services/com.deepin.filemanager.filedialog.service
    fi
}
function install_check_and_format() {
    green "Install cppcheck"
    sudo apt install -y cppcheck
    cat << 'EOF' | sudo tee /usr/local/bin/cppcheck
/usr/bin/cppcheck --enable=all --xml-version=2 --force "$@"
EOF
    green "Install checkstyle"
    CHECKSTYLE_VERSION=10.15.0
    sudo curl -L -o /usr/local/lib/checkstyle.jar https://mirror.ghproxy.com/https://github.com/checkstyle/checkstyle/releases/download/checkstyle-${CHECKSTYLE_VERSION}/checkstyle-${CHECKSTYLE_VERSION}-all.jar
    cat << 'EOF' | sudo tee /usr/local/bin/checkstyle
#!/usr/bin/env bash
java -jar /usr/local/lib/checkstyle.jar "$@"
EOF
    sudo chmod +x /usr/local/bin/checkstyle

    green "Install PMD"
    PMD_VERSION=6.55.0
    pushd /usr/local/lib || exit 1
    sudo bash << EOF
curl -L https://mirror.ghproxy.com/https://github.com/pmd/pmd/releases/download/pmd_releases%2F${PMD_VERSION}/pmd-bin-${PMD_VERSION}.zip --output pmd-bin-${PMD_VERSION}.zip
unzip pmd-bin-"${PMD_VERSION}".zip
mv -f pmd-bin-"${PMD_VERSION}" pmd
rm pmd-bin-"${PMD_VERSION}".zip
EOF
    popd || exit 1
    cat << 'EOF' | sudo tee /usr/local/bin/pmd
#!/usr/bin/env bash
/usr/local/lib/pmd/bin/run.sh pmd "$@"
EOF
    sudo chmod +x /usr/local/bin/pmd
    green "Install ktlint"
    ktlint_version=$(get_latest_release "pinterest/ktlint")
    sudo curl -L https://mirror.ghproxy.com/https://github.com/pinterest/ktlint/releases/download/"${ktlint_version}"/ktlint --output /usr/local/bin/ktlint
    sudo chmod +x /usr/local/bin/ktlint
    # python3
    if [ -f /usr/bin/python ]; then
        sudo rm -f /usr/bin/python
    fi
    if [ -f /usr/bin/python3 ] && [ ! -f /usr/bin/python ]; then
        sudo ln -s /usr/bin/python3 /usr/bin/python
    fi
    green "Install black pylint"
    sudo apt install pipx
    sudo pipx ensurepath
    green "设置pip默认源"
    export PIP_INDEX_URL=https://mirrors.aliyun.com/pypi/simple/
    green "把这句： export PIP_INDEX_URL=https://mirrors.aliyun.com/pypi/simple/ 加入到\$HOME/.barshrc \$HOME/.zshrc"
    pipx install black pylint lastversion

    # 激活 pipx 安装的 pylint 虚拟环境
    source "$HOME/.local/share/pipx/venvs/pylint/bin/activate"
    # 在虚拟环境中安装 pylint_json2checkstyle包
    python3 -m pip install pylint_json2checkstyle
    # 退出虚拟环境
    deactivate
    echo "pylint_json2checkstyle已成功安装在 pylint 的 pipx 环境中。"

    cat << 'EOF' | sudo tee /usr/local/bin/pylint
#!/bin/bash
$HOME/.local/bin/pylint --load-plugins=pylint_json2checkstyle.checkstyle_reporter --output-format=checkstyle -r y "$@"
EOF
    sudo chmod +x /usr/local/bin/pylint
    cat << 'EOF' | sudo tee /usr/local/bin/black
#!/bin/bash
$HOME/.local/bin/black "$@"
EOF
    sudo chmod +x /usr/local/bin/black
    green "Install shellcheck"
    #install_shell_check
    ARCH=$(uname -m)
    while [ -z "$shellcheck_version" ]; do
        shellcheck_version=$(get_latest_release "koalaman/shellcheck")
    done
    wget -O - https://mirror.ghproxy.com/https://github.com/koalaman/shellcheck/releases/download/"$shellcheck_version"/shellcheck-"$shellcheck_version".linux."$ARCH".tar.xz | tar -xJf -
    chmod +x shellcheck-"$shellcheck_version"/shellcheck || true
    sudo mv -f shellcheck-"$shellcheck_version"/shellcheck /usr/bin/ || true
    rm -rf shellcheck-"$shellcheck_version"
    green "Install shfmt"
    # shfmt
    case $ARCH in
        x86_64)
            arch=amd64
            ;;
        aarch64)
            arch=arm
            ;;
        mips64)
            arch=mips64el
            ;;
        *) ;;
    esac
    while [ -z "$shfmt_version" ]; do
        shfmt_version=$(get_latest_release "mvdan/sh")
    done
    wget https://mirror.ghproxy.com/https://github.com/mvdan/sh/releases/download/"$shfmt_version"/shfmt_"$shfmt_version"_linux_"$arch"
    sleep 1
    chmod +x shfmt_"$shfmt_version"_linux_"$arch" || exit
    sudo mv -f shfmt_"$shfmt_version"_linux_"$arch" /usr/bin/shfmt || exit
    green "请将下面的配置加入你的家目录的.bashrc 或者 .zshrc"
    green 'alias shellcheck="shellcheck -s bash -x"'
    green 'alias shfmt="shfmt -i 4 -bn -ci -sr -kp -l -w -d"'
}
# proxy
function install_proxytool() {
    green "Install proxychains privoxy"
    sudo apt install -y proxychains privoxy
}
function install_svn() {
    green "Install svn"
    sudo apt install rabbitvcs-cli rabbitvcs-core rabbitvcs-gedit rabbitvcs-nautilus
}
install_chrome() {
    green "Instal google chrome"
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    cat << EOF | sudo tee /etc/apt/sources.list.d/google-chrome.list
deb http://dl.google.com/linux/chrome/deb stable InRelease
EOF
    sudo apt update
    sudo apt -y install google-chrome-stable
}
function mount_90_mirror_samba() {
    yellow "密码可能更换，如果发现无效，找SCM更新"
    PASSWORD="f5Pf:d;r8<RG{c'p"
    MOUNTDIR="${1:data-hdd}"
    #安装autofs
    if ! command -v automount; then
        sudo apt -y install autofs cifs-utils linux-modules-extra-"$(uname -r)"
    fi
    #获取当前用户id，需要用户是sudo用户
    userid=$(id -u)
    sudo sed -i '/\/etc\/auto.samba/d' /etc/auto.master
    sudo sed -i "/+dir:\/etc\/auto.master.d/a\/- \/etc\/auto.samba uid=$userid,gid=$userid,--timeout=30,--ghost" /etc/auto.master

    #创建认证文件
    cat << EOF | sudo tee /etc/samba_credentials
username=mirror-user
password=$PASSWORD
EOF
    sudo chmod 600 /etc/samba_credentials
    #删除fstab中配置的挂载项
    sudo sed -i "/\/${MOUNTDIR}\/mirror/d" /etc/fstab
    sudo systemctl daemon-reload

    #卸载掉原挂载点
    if [[ -d /data-hdd/mirror ]]; then
        sudo umount "/${MOUNTDIR}/mirror"
    else
        sudo mkdir -p "/${MOUNTDIR}/mirror"
    fi
    sudo chown "$USER:$USER" "/${MOUNTDIR}/mirror"

    cat << EOF | sudo tee /etc/auto.samba
/${MOUNTDIR}/mirror -fstype=cifs,ro,credentials=/etc/samba_credentials,uid=$userid,iocharset=utf8 ://10.14.129.90/mirror
EOF
    #手动挂载一次
    sudo mount -t cifs //10.14.129.90/mirror "/${MOUNTDIR}/mirror" -o credentials=/etc/samba_credentials,uid="$userid"
    sudo umount "/${MOUNTDIR}/mirror"
    #自动挂载服务启动
    sudo systemctl restart autofs.service

    ls "/${MOUNTDIR}/mirror"
}
setup_build_node() {
    sudo apt -y install openjdk-17-jre
    install_docker_for_build "talos"
    if [[ -d /data ]]; then
        DATADIR="data"
    elif [[ -d /data-ssd ]]; then
        DATADIR="data-ssd"
    elif [[ -d /data-hdd ]]; then
        DATADIR="data-hdd"
    fi
    sudo mkdir -p "/${DATADIR}"/ccache "/${DATADIR}"/jenkins_remote_workdir
    sudo chown -R talos:talos "/${DATADIR}"/ccache
    mount_90_mirror_samba "${DATADIR}"
}

show_menu() {
    clear
    greenline "————————————————————————————————————————————————————"
    echo '
    ***********  配置Ubuntu环境  ***************
    环境:Ubuntu18.04/20.04/22.04/24.04
    脚本作用:环境配置
            --- Made by Liuxinsong ---'
    greenline "————————————————————————————————————————————————————"
    echo "请选择操作："

    # 特殊处理的项数组
    special_items=("安装项目构建用的docker环境" "挂载90的代码镜像samba服务到本地")
    for i in "${!menu_options[@]}"; do
        if [[ " ${special_items[*]} " =~ ${menu_options[i]} ]]; then
            # 如果当前项在特殊处理项数组中，使用特殊颜色
            cyan "$((i + 1)). ${menu_options[i]}"
        else
            # 否则，使用普通格式
            echo "$((i + 1)). ${menu_options[i]}"
        fi
    done
}

handle_choice() {
    local choice=$1
    # 检查输入是否为空
    if [[ -z $choice ]]; then
        echo -e "${RED}输入不能为空，请重新选择。${NC}"
        return
    fi

    # 检查输入是否为数字
    if ! [[ $choice =~ ^[0-9]+$ ]]; then
        echo -e "${RED}请输入有效数字!${NC}"
        return
    fi

    # 检查数字是否在有效范围内
    if [[ $choice -lt 1 ]] || [[ $choice -gt ${#menu_options[@]} ]]; then
        echo -e "${RED}选项超出范围!${NC}"
        echo -e "${YELLOW}请输入 1 到 ${#menu_options[@]} 之间的数字。${NC}"
        return
    fi

    # 执行命令
    if [ -z "${commands[${menu_options[$choice - 1]}]}" ]; then
        echo -e "${RED}无效选项，请重新选择。${NC}"
        return
    fi

    "${commands[${menu_options[$choice - 1]}]}"
}
automate() {
    for choice in "$@"; do
        if [[ $choice == 'q' ]]; then
            break
        fi
        handle_choice "$choice"
    done
}

if [ "$#" -gt 0 ]; then
    automate "$@"
else
    while true; do
        show_menu
        read -r -p "请输入选项的序号(输入q退出): " choice
        if [[ $choice == 'q' ]]; then
            break
        fi
        handle_choice "$choice"
        echo "按任意键继续..."
        read -r -n 1 # 等待用户按键
    done
fi
