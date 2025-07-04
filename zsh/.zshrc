# Move this block to the very top, before the p10k instant prompt
# if [[ -n "$SSH_CONNECTION" && -z "$TMUX" ]]; then
#   if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
#     tmux new-session -A -s default
#     exit 0
#   fi
# fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
# zinit light-mode for \
#     zdharma-continuum/zinit-annex-as-monitor \
#     zdharma-continuum/zinit-annex-bin-gem-node \
#     zdharma-continuum/zinit-annex-patch-dl \
#     zdharma-continuum/zinit-annex-rust
zinit light zdharma-continuum/zinit-annex-as-monitor
zinit light zdharma-continuum/zinit-annex-bin-gem-node
zinit light zdharma-continuum/zinit-annex-patch-dl
zinit light zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

# Add fzf to path
export PATH="$HOME/.fzf/bin:$PATH"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# zinit zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# zinit snippets (common ones only)
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::aws
zinit snippet OMZP::command-not-found
zinit snippet OMZP::archlinux
zinit snippet OMZP::kubectl

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# Eza
alias ld='eza -lD'
alias lf='eza -lF --color=always | grep -v /'
alias lh='eza -dl .* --group-directories-first'
alias ll='eza -al --group-directories-first'
alias lt='eza -al --color=always --sort=size | grep -v /'
alias ls='eza -al --sort=name --icons'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybindings
#bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

export FZF_DEFAULT_OPTS="--height=40% --layout=reverse --border"

# Auto-start tmux
 if [[ -n "$SSH_CONNECTION" && -z "$TMUX" ]]; then
   if command -v tmux &> /dev/null; then
     tmux new-session -A -s default
   fi
 fi

# fzf functions
fzf-vim-file() {
  local file
  file=$(fzf --query="$1" --select-1 --exit-0 --preview 'bat --style=numbers --color=always {} || head -100 {}')
  [[ -n "$file" ]] && vim "$file"
}

fzf-cd-file-dir() {
  local file
  file=$(fzf --query="$1" --select-1 --exit-0 --preview 'bat --style=numbers --color=always {} || head -100 {}')
  [[ -n "$file" ]] && cd "$(dirname "$file")"
}

# fzf functions keybindings
bindkey -s '^o' 'fzf-vim-file\n'
bindkey -s '\eo' 'fzf-cd-file-dir\n'

# eza alias
alias cd="z"

# Go.nvim
export PATH=$PATH:$GOPATH/bin

# bat alias
BAT_THEME="Catppuccin Mocha"

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/bin/tofu tofu

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


[[ -f ~/arch.zsh ]] && source ~/arch.zsh
[[ -f ~/ubuntu.zsh ]] && source ~/ubuntu.zsh
[[ -f ~/kube.zsh ]] && source ~/kube.zsh
