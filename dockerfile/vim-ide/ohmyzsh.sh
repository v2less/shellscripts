#!/bin/bash
install_oh_my_zsh() {
    set -x
    exec > >(tee -i /tmp/install_zsh.log)
    exec 2>&1
    sudo apt update || exit
    sudo apt install -y zsh fonts-powerline curl git || exit
    cd "$HOME" || exit
    mkdir -p "$HOME"/.local/share/fonts
    cd "$HOME"/.local/share/fonts || exit
    while true; do
        wget -O MesloLGS\ NF\ Regular.ttf https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf || true
        wget -O MesloLGS\ NF\ Bold.ttf https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf || true
        wget -O MesloLGS\ NF\ Italic.ttf https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf || true
        wget -O MesloLGS\ NF\ Bold\ Italic.ttf https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf || true
        fontsnu=$(find "$HOME"/.local/share/fonts/ -name "MesloLGS*" | wc -l)
        if [ "$fontsnu" == 4 ]; then
            break
        fi
    done
    fc-cache -v
    cd "$HOME" || exit
    echo "INFO Now start install zsh:"
    echo "When zsh have been installed,pleast input exit , back to continue run……"
    echo "When zsh have been installed,pleast input exit , back to continue run……"
    sleep 5
    i=0
    while true; do
        i=$((i + 1))
        wget -O - https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | bash - || true
        if [ -f "$HOME"/.oh-my-zsh/oh-my-zsh.sh ]; then
            break
        fi
        if [ $i -gt 30 ]; then
            echo "Check the internet."
            exit 1
        fi
    done
    cp "$HOME"/.oh-my-zsh/templates/zshrc.zsh-template "$HOME"/.zshrc
    while true; do
        if git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME"/.oh-my-zsh/custom/plugins/zsh-autosuggestions; then
            break
        fi
    done
    while true; do
        if git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME"/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting; then
            break
        fi
    done
    while true; do
        if git clone https://github.com/sukkaw/zsh-proxy.git "$HOME"/.oh-my-zsh/custom/plugins/zsh-proxy; then
            break
        fi
    done
    while true; do
        if git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME"/.oh-my-zsh/custom/themes/powerlevel10k; then
            break
        fi
    done
    sed -ri '/^plugins/c plugins=(git zsh-proxy colored-man-pages zsh-autosuggestions zsh-syntax-highlighting)' "$HOME"/.zshrc
    sed -ri '/^#[ *]HIST_STAMPS/c HIST_STAMPS="yyyy-mm-dd"' "$HOME"/.zshrc
    sed -ri '/^ZSH_THEME/c ZSH_THEME="powerlevel10k/powerlevel10k"' "$HOME"/.zshrc
    sed -ri "/^POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true/d" "$HOME"/.zshrc
    sed -ri "\$aPOWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true" "$HOME"/.zshrc
    cat <<EOF | tee -a "$HOME"/.zshrc
alias shfmt="shfmt -i 4 -bn -ci -sr -kp -l -w -d"
alias shellcheck="shellcheck -s bash -x"
alias sedblank="sed -ri 's@[[:space:]]*\$@@g'"
EOF
    echo "change default sh to zsh:"
    chsh -s "$(which zsh)"
    echo "$SHELL"
}
install_oh_my_zsh
