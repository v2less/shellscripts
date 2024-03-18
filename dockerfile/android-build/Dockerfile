FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

LABEL maintainer="v2less <waytoarcher@gmail.com>"

ENV PATH="/home/user/bin:${PATH}"
RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak
RUN echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse" >>/etc/apt/sources.list
RUN echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse" >>/etc/apt/sources.list
RUN echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-security main restricted universe multiverse" >>/etc/apt/sources.list

# Taking into account layer structure, everything should be done within one layer.
RUN apt-get update && apt-get upgrade -y && \
    # Install Google recommended packages ( https://source.android.com/setup/build/initializing#installing-required-packages-ubuntu-1804 )
    apt-get install -y git-core gnupg flex bison build-essential zip \
    curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev \
    x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev \
    libxml2-utils xsltproc unzip fontconfig \
    # Install additional packages
    swig libssl-dev flex bison device-tree-compiler mtools gettext libncurses5 libgmp-dev \
    libmpc-dev cpio rsync dosfstools kmod gdisk wget git meson cmake libglib2.0-dev \
    # Install additional packages (for building mesa3d, libcamera and other meson-based components)
    python3-pip pkg-config python3-dev ninja-build aapt python2.7 vim openjdk-11-jdk \
    tzdata net-tools bc locales \
    # Install additional packages (required by repo utility)
    # python-is-python3 \
    # Add extra tools
    sudo && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    locale-gen en_US.UTF-8 && \
    # Install additional packages (for building mesa3d, libcamera and other meson-based components)
    pip3 install mako jinja2 ply pyyaml pyjwt requests -i https://pypi.tuna.tsinghua.edu.cn/simple
RUN ln -sf /usr/bin/python2.7 /usr/bin/python && ln -sf /usr/bin/python2.7 /usr/bin/python2
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV RUN_USER user
ENV RUN_UID 1002

ENV USER_HOME /home/${RUN_USER}

RUN mkdir -pv ${USER_HOME}
# Create new user
RUN adduser \
    --gecos 'Build User' \
    --shell '/usr/bin/bash' \
    --uid ${RUN_UID} \
    --disabled-login \
    --disabled-password ${RUN_USER} \
    && adduser ${RUN_USER} sudo

# Create project path
RUN mkdir -pv ${USER_HOME}/build
WORKDIR ${USER_HOME}/build

RUN chown -R ${RUN_USER}:${RUN_USER} ${USER_HOME} && chmod -R 775 ${USER_HOME}

# Ensure sudo group users are not
# asked for a password when using
# sudo command by ammending sudoers file
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> \
/etc/sudoers
RUN /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' >/etc/timezone

# Pass control to a newly created user
USER ${RUN_USER}

# Install repo
#RUN wget -P ${USER_HOME}/bin https://storage.googleapis.com/git-repo-downloads/repo && chmod a+x ${USER_HOME}/bin/repo
COPY ./repo ${USER_HOME}/bin/repo

RUN git config --global user.name "v2less" && git config --global user.email "waytoarcher@gmail.com"
ENV USE_CCACHE=0
CMD [ "/bin/bash" ]
