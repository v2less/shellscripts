#!/bin/bash
apt install -y libncurses-dev python3-dev
git clone -b master --depth 1 https://mirror.ghproxy.com/https://github.com/vim/vim.git || exit 1
cd vim || exit 1
export LDFLAGS="-fno-lto"
./configure --with-features=huge \
            --enable-multibyte \
            --enable-rubyinterp=yes \
            --enable-python3interp=yes \
            --with-python3-config-dir=$(python3-config --configdir) \
            --enable-perlinterp=yes \
            --enable-luainterp=yes \
            --enable-gui=gtk2 \
            --enable-cscope \
            --prefix=/usr/local

make VIMRUNTIMEDIR=/usr/local/share/vim/vim91

make install
ln -sf /usr/local/bin/vim /bin/vi
ln -sf /usr/local/bin/vim /usr/bin/vim

