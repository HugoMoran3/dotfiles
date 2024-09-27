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

# Function to restore backed up files
restore_backup() {
    local file=$1
    local backup=$(ls -t $REAL_HOME/$file.backup.* 2>/dev/null | head -n1)
    if [ -n "$backup" ]; then
        echo "Restoring $file from backup"
        run_as_user mv "$backup" "$REAL_HOME/$file"
    else
        echo "No backup found for $file"
    fi
}

echo "Uninstalling dotfiles and related software..."

# Unstow dotfiles
echo "Unstowing dotfiles..."
run_as_user << EOF
cd $PWD
stow -D -t $REAL_HOME *
EOF

# Restore backed up files
echo "Restoring original configuration files..."
restore_backup ".zshrc"
restore_backup ".tmux.conf"
restore_backup ".config/nvim/init.vim"

# Uninstall Nerd Fonts
echo "Removing Nerd Fonts..."
run_as_user rm -rf $REAL_HOME/.local/share/fonts/JetBrainsMono

# Uninstall zinit
echo "Removing zinit..."
run_as_user rm -rf $REAL_HOME/.zinit

# Uninstall fzf
echo "Removing fzf..."
run_as_user $REAL_HOME/.fzf/uninstall --all
run_as_user rm -rf $REAL_HOME/.fzf

# Remove tpm (Tmux Plugin Manager)
echo "Removing tpm..."
run_as_user rm -rf $REAL_HOME/.tmux/plugins/tpm

# Remove eza repository
echo "Removing eza repository..."
rm -f /etc/apt/sources.list.d/gierens.list
rm -f /etc/apt/keyrings/gierens.gpg

# Uninstall packages
echo "Uninstalling packages..."
apt remove -y eza stow
apt autoremove -y

echo "Uninstallation complete. The following actions were taken:"
echo "1. Dotfiles were unstowed"
echo "2. Original configuration files were restored (if backups were found)"
echo "3. Nerd Fonts, zinit, fzf, and tpm were removed"
echo "4. The eza repository was removed"
echo "5. eza and stow packages were uninstalled"
echo ""
echo "Note: git, zsh, and tmux were not uninstalled as they may be used by other applications."
echo "If you wish to remove these, please do so manually."
echo ""
echo "Please log out and log back in to ensure all changes take effect."