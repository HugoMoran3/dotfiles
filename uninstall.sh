#!/bin/bash

# Check if script is run with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root or with sudo"
    exit 1
fi

# Get the actual user's home directory
REAL_USER=$SUDO_USER
REAL_HOME=$(getent passwd $REAL_USER | cut -d: -f6)

# Function to run commands as the real user
run_as_user() {
    sudo -u $REAL_USER bash << EOF
    $@
EOF
}

echo "Starting uninstallation process..."

# Remove Neovim
echo "Removing Neovim..."
rm -rf /opt/nvim
rm -f /usr/local/bin/nvim

# Remove eza repository
echo "Removing eza repository..."
rm -f /etc/apt/keyrings/gierens.gpg
rm -f /etc/apt/sources.list.d/gierens.list

# Update package lists
apt update -y

# Remove installed packages
echo "Removing installed packages..."
apt remove -y git zsh tmux eza stow
apt autoremove -y

# Remove user-specific installations (run as real user)
echo "Removing user-specific installations..."
run_as_user << 'EOF'
    # Remove zinit
    rm -rf ~/.zinit

    # Remove fzf
    rm -rf ~/.fzf
    # Remove fzf config from ~/.bashrc and ~/.zshrc
    sed -i '/^# BEGIN fzf/,/^# END fzf/d' ~/.bashrc 2>/dev/null
    sed -i '/^# BEGIN fzf/,/^# END fzf/d' ~/.zshrc 2>/dev/null

    # Remove tpm and tmux plugins
    rm -rf ~/.tmux/plugins

    # Remove Nerd Fonts
    echo "Removing Nerd Fonts..."
    rm -rf ~/.local/share/fonts/JetBrainsMono
    # Update font cache
    fc-cache -f -v
EOF

# Restore backed up configuration files if they exist
echo "Restoring backup files if they exist..."
for file in "$REAL_HOME"/*.backup.*; do
    if [ -f "$file" ]; then
        original_file=$(echo "$file" | sed 's/\.backup\.[0-9]\{14\}$//')
        echo "Restoring $original_file"
        mv "$file" "$original_file"
    fi
done

# Reset shell to bash if zsh was default
if [ "$(getent passwd $REAL_USER | cut -d: -f7)" = "/usr/bin/zsh" ]; then
    echo "Resetting default shell to bash..."
    chsh -s /bin/bash $REAL_USER
fi

echo "Uninstallation complete. The following changes were made:"
echo "1. Removed Neovim from /opt"
echo "2. Removed eza repository and package"
echo "3. Uninstalled git, zsh, tmux, eza, and stow"
echo "4. Removed zinit configuration"
echo "5. Removed fzf and its configuration"
echo "6. Removed tmux plugin manager and plugins"
echo "7. Removed JetBrainsMono Nerd Font"
echo "8. Restored any backed up configuration files"
echo "9. Reset default shell to bash (if necessary)"
echo ""
echo "Note: You may need to restart your terminal for all changes to take effect."