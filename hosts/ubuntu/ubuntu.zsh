# Debian/Ubuntu specific configuration

# docker compose alias
alias ddown="docker compose down"
alias dup="docker compose up -d"
alias dred="docker compose down && docker compose up -d"
alias dockcheck="$HOME/.local/bin/dockcheck.sh"

alias cscli="docker exec crowdsec cscli"
alias bat="batcat"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
