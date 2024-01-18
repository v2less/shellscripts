FROM debian:bookworm-slim
# Set the shell to bash
SHELL ["/bin/bash", "-c"]
# Make sure all is up to date
ENV LANG C.UTF-8
ENV TZ 'Asia/Shanghai'
ENV DEBIAN_FRONTEND=noninteractive
RUN set -ex \
    && rm /bin/sh && ln -s /bin/bash /bin/sh \
    && mkdir -p /usr/loca/bin \
    && sed -i "s%http://deb.debian.org%http://mirrors.tuna.tsinghua.edu.cn%g" /etc/apt/sources.list.d/debian.sources
RUN apt update && apt upgrade -y
RUN apt-get install -y python3-pip git curl \
                       build-essential cmake python3-dev libncurses5-dev

COPY ./vim_with_python.sh /tmp/vim_with_python.sh
WORKDIR /tmp
RUN /tmp/vim_with_python.sh

# Create a user to setup for developing
RUN useradd -ms /bin/bash dev
USER dev
COPY ./vim_install.sh /tmp/vim_install.sh
COPY ./vimrc /tmp/vimrc
RUN /tmp/vim_install.sh

# Finally install commonly used libraries for auto-complete
WORKDIR /home/dev/workspace
CMD vim
