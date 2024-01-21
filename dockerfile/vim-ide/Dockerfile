FROM debian:bookworm-slim

# Set the shell to bash
SHELL ["/bin/bash", "-c"]

# Make sure all is up to date
ENV LANG C.UTF-8
ENV TZ 'Asia/Shanghai'
ENV DEBIAN_FRONTEND=noninteractive

RUN set -ex \
    && rm /bin/sh && ln -s /bin/bash /bin/sh \
    && mkdir -p /usr/local/bin \
    && sed -i "s%http://deb.debian.org%http://mirrors.tuna.tsinghua.edu.cn%g" /etc/apt/sources.list.d/debian.sources \
    && apt update && apt upgrade -y \
    && apt-get install -y python3-pip git curl build-essential cmake python3-dev libncurses5-dev wget universal-ctags \
                          gcc g++ gdb groovy default-jdk nodejs npm ninja-build automake libtool gdb gettext gnu-standards autopoint \
                          fakeroot libncurses-dev xz-utils libssl-dev bc flex libelf-dev bison gawk openssl dkms libudev-dev libpci-dev \
                          libiberty-dev autoconf device-tree-compiler cpio rsync python3-requests bash-completion iproute2 iputils-ping \
                          subversion git-svn git-cvs cscope coreutils less file tree dos2unix gnupg zip unzip ssh-client lrzsz

RUN wget https://golang.org/dl/go1.21.6.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go1.21.6.linux-amd64.tar.gz \
    && rm go1.21.6.linux-amd64.tar.gz

# Set Go environment variables
ENV PATH=$PATH:/usr/local/go/bin
ENV GOPATH=/go
ENV GOBIN=/go/bin
# Install ShellCheck black
RUN apt-get install -y shellcheck black                             \
    && apt-get clean                                                \
    && (rm -rf /var/lib/apt/lists/*                                 \
        /var/tmp/* /var/tmp/.[!.]*                                  \
        /tmp/* /tmp/.[!.]* || true)

# Install shfmt
RUN wget -O /usr/local/bin/shfmt https://github.com/mvdan/sh/releases/download/v3.7.0/shfmt_v3.7.0_linux_amd64 \
    && chmod +x /usr/local/bin/shfmt

# Copy necessary files after creating directories
WORKDIR /tmp
COPY vim_with_python.sh /tmp/
RUN /tmp/vim_with_python.sh

# Create a user to set up for developing
RUN useradd -ms /bin/bash dev
RUN adduser dev sudo
# Allow user to run sudo commands without password
RUN echo 'dev ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
# Finally, install commonly used libraries for auto-complete
USER dev
COPY vim_install.sh vimrc /var/tmp/
RUN /var/tmp/vim_install.sh
COPY ohmyzsh.sh /var/tmp/
RUN /var/tmp/ohmyzsh.sh
WORKDIR /home/dev/workspace
CMD vim
