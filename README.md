# Install dotfiles

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


NvChad
https://nvchad.com/docs/quickstart/install/

    git clone https://github.com/NvChad/starter ~/.config/nvim && nvim
FZF

Tmux

Tmux Plugin Manager

    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  After using stow on the dotfiles directory 
  

    tmux source ~/.tmux.conf

In Tmux press `prefix + I` (capital i, as in Install) to fetch the plugin.
  

Nerd Font - [Jet Brains Mono](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip)
    
    1.) Download a Nerd Font
    
    2.) Unzip and copy to ~/.fonts
    
    3.) Run the command fc-cache -fv to manually rebuild the font cache
