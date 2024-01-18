#!/bin/bash
    mkdir -p "$HOME"/.vim/bundle
    mkdir -p "$HOME"/.vim/.backup
    mkdir -p "$HOME"/.vim/.undo
    mkdir -p "$HOME"/.vim/.swap
    git clone https://mirror.ghproxy.com/https://github.com/VundleVim/Vundle.vim.git "$HOME"/.vim/bundle/Vundle.vim || exit
    cp ./vimrc "$HOME"/.vimrc || exit
    # YouCompleteMe 是基于 Vim 的 omnifunc 机制来实现自动补全功能
    if [ -d "$HOME"/.vim/bundle/YouCompleteMe ]; then
        :
    else
        git clone https://mirror.ghproxy.com/https://github.com/Valloric/YouCompleteMe.git "$HOME"/.vim/bundle/YouCompleteMe
        cd "$HOME"/.vim/bundle/YouCompleteMe || exit
	sed -i "s%\ https://github.com%\ https://mirror.ghproxy.com/https://github.com%g" .git/config
        git submodule update --init --recursive
        #./install.sh --clang-completer --system-libclang
        if command -v go env; then
            python3 install.py --clangd-completer --go-completer
        else
            python3 install.py --clangd-completer
        fi
    fi
    #vim +PluginInstall +qall
    vim -E -s -u $HOME/.vimrc +PluginInstall +qall

