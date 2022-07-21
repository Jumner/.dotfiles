
#!/bin/sh
sudo pacman --needed -S base-devel git
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

yay
yay --noconfirm -S adwaita-icon-theme adobe-source-code-pro-fonts bat betterdiscordctl bibata-cursor-theme bitwarden discord dunst eww-git ffmpeg ffmpeg4.4 ffnvcodec-headers firefox flameshot git kdeconnect layan-cursor-theme-git layan-gtk-theme-git lxappearance neofetch neovim nerd-fonts-dejavu-complete nerd-fonts-jetbrains-mono nerd-fonts-sf-mono nitrogen noisetorch noto-fonts noto-fonts-extra paru pfetch picom-ibhagwan-git qogir-gtk-theme redshift screen starship zsh noto-fonts-cjk alacritty-ligatures-git ttf-jetbrains-mono emacs ripgrep papirus-icon-theme alsa-utils brave-bin noto-fonts-emoji 

#=== Post install script ===#

# This is some post install stuff

# Doom Emacs
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.emacs.d
yes | ~/.emacs.d/bin/doom install
doom sync

