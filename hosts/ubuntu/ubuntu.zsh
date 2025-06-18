# Debian/Ubuntu specific configuration

# docker compose alias
alias dockdown="docker compose down"
alias dockup="docker compose up -d"
alias dockcheck="$HOME/.local/bin/dockcheck.sh"

alias cscli="docker exec crowdsec cscli"
alias bat="batcat"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
