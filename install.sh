#!/bin/bash

# Check if script is run with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root or with sudo"
    exit
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

# Define backup_file function
backup_file() {
    local file=$1
    if [ -e "$REAL_HOME/$file" ]; then
        echo "Backing up existing $file"
        mv "$REAL_HOME/$file" "$REAL_HOME/$file.backup.$(date +%Y%m%d%H%M%S)"
    fi
}

# Load OS information
. /etc/os-release

# OS-specific installation - PRETTY_NAME variable is from the os-release information
echo "Detected OS: $PRETTY_NAME"
case $ID in
    ubuntu|debian)
        echo "Installing for Ubuntu/Debian..."
        
        # Update package lists
        apt update -y

        # Install Neovim with pre-built binary
        curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
        sudo rm -rf /opt/nvim
        sudo tar -C /opt -xzf nvim-linux64.tar.gz

        # Add eza repository
        echo "Adding eza repository..."
        mkdir -p /etc/apt/keyrings
        curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list
        chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list

        # Update package lists again
        apt update -y

        # Install dependencies
        apt install -y git zsh tmux eza stow

        
        # Install Nerd Fonts
        echo "Installing Nerd Fonts..."
        ./nerdfonts.sh
        if [ $? -eq 0 ]; then
            echo "Nerd Fonts installed successfully"
        else
            echo "Error occurred while installing Nerd Fonts"
            exit 1
        fi

        ;;

    arch|endeavouros)
        echo "Installing for Arch/EndeavourOS..."
        
        # Update package lists
        pacman -Syu --noconfirm

        # List of packages to be installed
        PKGS=("eza" "zsh" "tmux" "git" "neovim" "fzf" "stow" "ttf-jetbrains-mono-nerd ")

        # Install dependencies
        pacman -S --noconfirm "{$PKGS[@]}"
        ;;

    fedora)
        echo "Installing for Fedora..."
        
        # Update package lists
        dnf update -y

        # Install Neovim with pre-built binary
        curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
        sudo rm -rf /opt/nvim
        sudo tar -C /opt -xzf nvim-linux64.tar.gz

        # Install dependencies
        dnf install -y git zsh tmux eza stow
        ;;

    *)
        echo "Unsupported distribution: $PRETTY_NAME"
        echo "This script supports Ubuntu, Debian, Arch, EndeavourOS, and Fedora"
        exit 1
        ;;
esac

# Check if installation was successful
if [ $? -eq 0 ]; then
    echo "Dependencies installed successfully"
else
    echo "Error occurred while installing dependencies"
    exit 1
fi

# Print installed versions
echo "Installed versions:"
git --version
zsh --version
tmux -V
eza --version
stow --version


# Before stowing, backup existing files
echo "Backing up existing configuration files..."
backup_file ".config/nvim"
backup_file ".zshrc"
backup_file ".tmux.conf"

# Stow dotfiles
echo "Stowing dotfiles..."
if stow nvim; then
    echo "Successfully stowed nvim configuration"
else
    echo "Error stowing nvim configuration"
    exit 1
fi

if stow -t ~/ zsh; then
    echo "Successfully stowed zsh configuration"
else
    echo "Error stowing zsh configuration"
    exit 1
fi

if stow -t ~/ tmux; then
    echo "Successfully stowed tmux configuration"
else
    echo "Error stowing tmux configuration"
    exit 1
fi

# Switch to Zsh for the rest of the script
echo "Switching to Zsh for the remainder of the script..."
sudo -u $REAL_USER zsh << 'ZSHSCRIPT'
# Set ZDOTDIR to ensure .zshrc is sourced from the correct location
export ZDOTDIR=$HOME

# Source .zshrc
echo "Sourcing .zshrc..."
source $ZDOTDIR/.zshrc

# Install zinit
echo "Installing zinit..."
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"

# Source .zshrc
echo "Sourcing .zshrc..."
source $ZDOTDIR/.zshrc

# Update zinit
echo "Updating zinit..."
zinit self-update

# Check if zinit installation was successful
if [ $? -eq 0 ]; then
    echo "zinit installed and updated successfully"
else
    echo "Error occurred while installing or updating zinit"
    exit 1
fi

# Install fzf
echo "Installing fzf..."
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf

# Run fzf install script
echo "Running fzf install script..."
~/.fzf/install --all

# Check if fzf installation was successful
if [ $? -eq 0 ]; then
    echo "fzf installed successfully"
else
    echo "Error occurred while installing fzf"
    exit 1
fi

# Print fzf version
echo "Installed fzf version:"
~/.fzf/bin/fzf --version

# Install tpm (Tmux Plugin Manager)
echo "Installing tpm (Tmux Plugin Manager)..."
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Check if tpm installation was successful
if [ $? -eq 0 ]; then
    echo "tpm installed successfully"
else
    echo "Error occurred while installing tpm"
    exit 1
fi

echo "Verifying installations..."

# Check apt installed packages
for pkg in git zsh tmux eza stow; do
    if command -v $pkg > /dev/null; then
        echo "$pkg is installed"
    else
        echo "ERROR: $pkg is not installed"
    fi
done

# Check Neovim installation
if [ -d "$HOME/.local/bin/nvim" ]; then
    echo "Neovim is installed"
else
    echo "ERROR: Neovim is not installed"
fi

# Check Nerd Fonts installation
if [ -d "$HOME/.local/share/fonts/JetBrainsMono" ]; then
    echo "JetBrainsMono Nerd Font is installed"
else
    echo "ERROR: JetBrainsMono Nerd Font is not installed"
fi

# Check zinit installation
if [ -d "$HOME/.zinit" ]; then
    echo "zinit is installed"
else
    echo "ERROR: zinit is not installed"
fi

# Check fzf installation
if [ -d "$HOME/.fzf" ]; then
    echo "fzf is installed"
else
    echo "ERROR: fzf is not installed"
fi

# Check tpm installation
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "tpm is installed"
else
    echo "ERROR: tpm is not installed"
fi

echo "Verification complete."

ZSHSCRIPT

echo "Script execution completed."
