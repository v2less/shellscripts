#!/bin/bash -x
pushd /var/tmp
mkdir -p "$HOME"/.vim/bundle
mkdir -p "$HOME"/.vim/.backup
mkdir -p "$HOME"/.vim/.undo
mkdir -p "$HOME"/.vim/.swap
[ -d "$HOME"/.vim/bundle/Vundle.vim ] || git clone https://github.com/VundleVim/Vundle.vim.git "$HOME"/.vim/bundle/Vundle.vim || exit
cp  ./vimrc "$HOME"/.vimrc || exit
# YouCompleteMe 是基于 Vim 的 omnifunc 机制来实现自动补全功能
if [ -d "$HOME"/.vim/bundle/YouCompleteMe ]; then
    :
else
    git clone https://github.com/Valloric/YouCompleteMe.git "$HOME"/.vim/bundle/YouCompleteMe
    cd "$HOME"/.vim/bundle/YouCompleteMe || exit
    sed -i "s%\ https://github.com%\ https://mirror.ghproxy.com/https://github.com%g" .git/config
    git submodule update --init --recursive
    rm -rf /ycmd/.git
    #python3 install.py --clangd-completer --go-completer --java-completer
    python3 install.py --all
fi
#vim +PluginInstall +qall
vim -E -s -u "$HOME"/.vimrc +PluginInstall +qall
popd

