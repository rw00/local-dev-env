#!/usr/bin/env bash
set -euo pipefail

echo "Starting bootstrapping process..."

OS="$(uname -s)"
if [ "$OS" = "Darwin" ]; then
    echo "macOS detected."
    # Add Homebrew to PATH just in case it's installed but not in the current shell's PATH
    export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
    
    # Install Homebrew if not installed
    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        echo "Homebrew is already installed."
    fi
    # Install Ansible
    if ! command -v ansible &> /dev/null; then
        echo "Installing Ansible..."
        brew install ansible
    else
        echo "Ansible is already installed."
    fi
elif [ "$OS" = "Linux" ]; then
    echo "Linux detected."
    if command -v apt-get &> /dev/null; then
        echo "Updating APT repository..."
        sudo apt-get update -y
        if ! command -v ansible &> /dev/null; then
            echo "Installing Ansible..."
            sudo apt-get install -y ansible
        else
            echo "Ansible is already installed."
        fi
    else
        echo "Unsupported package manager. Please install Ansible manually."
        exit 1
    fi
else
    echo "Unsupported OS: $OS"
    exit 1
fi

echo ""
echo "Bootstrapping complete."
echo "Running the local Ansible environment setup..."
# Use ansible-playbook to run the local playbook, asking for password for elevated privileges
ansible-playbook main.yml -i inventory --ask-become-pass

echo ""
echo "Setup is complete!"
