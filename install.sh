#!/bin/bash

# Check if script is run with sudo
if [ "$EUID" -ne 0 ]
  then echo "Please run as root or with sudo"
  exit
fi

# Update package lists
apt update -y

# Add eza repository
echo "Adding eza repository..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list
chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list

# Update package lists again to include the new repository
apt update -y

# Install dependencies
apt install -y git zsh tmux eza stow

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

stow .

zsh

# Install Nerd Fonts
echo "Installing Nerd Fonts..."
./nerdfonts.sh
if [ $? -eq 0 ]; then
    echo "Nerd Fonts installed successfully"
else
    echo "Error occurred while installing Nerd Fonts"
    exit 1
fi

# Install zinit
echo "Installing zinit..."
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"

# Source .zshrc
echo "Sourcing .zshrc..."
source ~/.zshrc

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