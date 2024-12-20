# Install dotfiles

Steps
chmod +x install.sh
chmod +x nerdfonts.sh

sudo ./install.sh

sudo rm ~/.zshrc

stow nvim
stow -t ~/ zsh
stow -t ~/ tmux

tmux source ~/.tmux.conf

In Tmux press `prefix + I` (capital i, as in Install) to fetch the plugin.

source ~/.zshrc

## Requirements:

Install git, zsh and wget/curl via cli

Included: 

 - Powerlevel10k
 - Zsh
 - Zinit
 - NvChad
 - Tmux
 - Tmux Plugin Manager
 - FZF

Zinit
https://github.com/zdharma-continuum/zinit](https://github.com/zdharma-continuum/zinit?tab=readme-ov-file#automatic

    bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
    
    source ~/.zshrc
    
    zinit self-update


FZF

Tmux

Tmux Plugin Manager

    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  After using stow on the dotfiles directory 
  

    tmux source ~/.tmux.conf

In Tmux press `prefix + I` (capital i, as in Install) to fetch the plugin.
