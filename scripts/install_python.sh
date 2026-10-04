#!/bin/bash
set -e

if ! python3 -m pip --version &> /dev/null; then
    if command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y python3 python3-pip python3-venv
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y python3 python3-pip
    elif command -v yum &> /dev/null; then
        sudo yum install -y python3 python3-pip
    elif command -v apk &> /dev/null; then
        sudo apk add python3 py3-pip
    elif command -v pacman &> /dev/null; then
        sudo pacman -Syu --noconfirm python python-pip
    elif command -v zypper &> /dev/null; then
        sudo zypper install -y python3 python3-pip
    else
        echo "Unsupported package manager. Please install Python 3 and pip manually."
        exit 1
    fi
fi
