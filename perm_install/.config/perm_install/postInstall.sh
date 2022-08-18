# This is some post install stuff

# Doom Emacs
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.emacs.d
yes | ~/.emacs.d/bin/doom install
doom sync

# SSH Keys
ssh-keygen -t ed25519 -C "justin462@protonmail.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Oh my zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
rm .zshrc
mv .zshrc.pre-oh-my-zsh .zshrc

# Vim Plug
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Rust-analyzer
git clone https://github.com/rust-lang/rust-analyzer.git 
cd rust-analyzer
cargo xtask install --server
