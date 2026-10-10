#!/bin/bash
set -e

export PATH="$HOME/.local/bin:$PATH"

if ! command -v ansible &> /dev/null; then
    if ! command -v pipx &> /dev/null; then
        if command -v apt &> /dev/null; then
            sudo apt update
            sudo apt install -y pipx
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y pipx
        elif command -v yum &> /dev/null; then
            sudo yum install -y pipx
        elif command -v apk &> /dev/null; then
            sudo apk add pipx
        elif command -v pacman &> /dev/null; then
            sudo pacman -Syu --noconfirm pipx
        elif command -v zypper &> /dev/null; then
            sudo zypper install -y pipx
        else
            echo "Unsupported package manager. Please install pipx manually."
            exit 1
        fi
    fi

    pipx ensurepath
    pipx install --include-deps ansible
else
    echo "Ansible is already installed."
fi

ansible --version
