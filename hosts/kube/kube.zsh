# Kubernetes/Helm configuration
# kubectl autocompletion
if command -v kubectl &> /dev/null; then
    source <(kubectl completion zsh)
fi

# helm autocompletion
if command -v helm &> /dev/null; then
    source <(helm completion zsh)
fi

# docker compose alias
alias dockdown="docker compose down"
alias dockup="docker compose up -d"
alias dockcheck="$HOME/.local/bin/dockcheck.sh"

alias cscli="docker exec crowdsec cscli"


eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
