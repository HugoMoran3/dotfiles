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

backup_file() {
    local file=$1
    if [ -e "$REAL_HOME/$file" ]; then
        echo "Backing up existing $file"
        run_as_user mv "$REAL_HOME/$file" "$REAL_HOME/$file.backup.$(date +%Y%m%d%H%M%S)"
    fi
}

# Stow dotfiles
echo "Stowing dotfiles..."
run_as_user << EOF
cd $PWD
echo "Current directory: \$(pwd)"
echo "Contents of current directory:"
ls -la

echo "Backing up existing files if necessary..."
$(declare -f backup_file)
backup_file ".zshrc"
backup_file ".tmux.conf"
backup_file ".config/nvim/init.vim"

echo "Running stow..."

# Stow zsh separately with --no-folding
if [ -d "zsh" ]; then
    echo "Stowing zsh files..."
    stow --no-folding -v -t $REAL_HOME zsh
    if [ \$? -ne 0 ]; then
        echo "Error occurred while stowing zsh files."
        exit 1
    fi
fi

# Stow all other dotfiles
echo "Stowing other dotfiles..."
stow -v -t $REAL_HOME \$(ls -d */ | grep -v '^zsh/\$')

if [ \$? -eq 0 ]; then
    echo "Stow completed successfully."
else
    echo "Error occurred during stow operation."
    exit 1
fi
EOF

# Install Nerd Fonts
echo "Installing Nerd Fonts..."
run_as_user ./nerdfonts.sh
if [ $? -eq 0 ]; then
    echo "Nerd Fonts installed successfully"
else
    echo "Error occurred while installing Nerd Fonts"
    exit 1
fi

# Install zinit
echo "Installing zinit..."
run_as_user bash -c "\$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"

# Source .zshrc
echo "Sourcing .zshrc..."
run_as_user source $REAL_HOME/.zshrc

# Update zinit
echo "Updating zinit..."
run_as_user zinit self-update

# Check if zinit installation was successful
if [ $? -eq 0 ]; then
    echo "zinit installed and updated successfully"
else
    echo "Error occurred while installing or updating zinit"
    exit 1
fi

# Install fzf
echo "Installing fzf..."
run_as_user git clone --depth 1 https://github.com/junegunn/fzf.git $REAL_HOME/.fzf

# Run fzf install script
echo "Running fzf install script..."
run_as_user $REAL_HOME/.fzf/install --all

# Check if fzf installation was successful
if [ $? -eq 0 ]; then
    echo "fzf installed successfully"
else
    echo "Error occurred while installing fzf"
    exit 1
fi

# Print fzf version
echo "Installed fzf version:"
run_as_user $REAL_HOME/.fzf/bin/fzf --version

# Install tpm (Tmux Plugin Manager)
echo "Installing tpm (Tmux Plugin Manager)..."
run_as_user git clone https://github.com/tmux-plugins/tpm $REAL_HOME/.tmux/plugins/tpm

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
if [ -d "$REAL_HOME/.local/share/fonts/JetBrainsMono" ]; then
    echo "JetBrainsMono Nerd Font is installed"
else
    echo "ERROR: JetBrainsMono Nerd Font is not installed"
fi

# Check zinit installation
if [ -d "$REAL_HOME/.zinit" ]; then
    echo "zinit is installed"
else
    echo "ERROR: zinit is not installed"
fi

# Check fzf installation
if [ -d "$REAL_HOME/.fzf" ]; then
    echo "fzf is installed"
else
    echo "ERROR: fzf is not installed"
fi

# Check tpm installation
if [ -d "$REAL_HOME/.tmux/plugins/tpm" ]; then
    echo "tpm is installed"
else
    echo "ERROR: tpm is not installed"
fi

echo "Verification complete."
echo "Installation completed for user $REAL_USER. Please log out and log back in to ensure all changes take effect."