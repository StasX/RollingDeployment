#!/bin/bash
set -e

TERRAFORM_VERSION="1.16.5"

if ! command -v terraform &> /dev/null; then
    case "$(uname -m)" in
        x86_64|amd64)
            ARCH="amd64"
            ;;
        aarch64|arm64)
            ARCH="arm64"
            ;;
        *)
            echo "Unsupported architecture: $(uname -m)"
            exit 1
            ;;
    esac

    if ! command -v curl &> /dev/null || ! command -v unzip &> /dev/null; then
        if command -v apt &> /dev/null; then
            sudo apt update
            sudo apt install -y curl unzip
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y curl unzip
        elif command -v yum &> /dev/null; then
            sudo yum install -y curl unzip
        elif command -v apk &> /dev/null; then
            sudo apk add curl unzip
        elif command -v pacman &> /dev/null; then
            sudo pacman -Syu --noconfirm curl unzip
        elif command -v zypper &> /dev/null; then
            sudo zypper install -y curl unzip
        else
            echo "Unsupported package manager."
            exit 1
        fi
    fi

    if ! command -v mktemp &> /dev/null; then
        if command -v apt &> /dev/null; then
            sudo apt update && sudo apt install -y coreutils
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y coreutils
        elif command -v yum &> /dev/null; then
            sudo yum install -y coreutils
        elif command -v apk &> /dev/null; then
            sudo apk add coreutils
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm coreutils
        elif command -v zypper &> /dev/null; then
            sudo zypper install -y coreutils
        else
            echo "mktemp is required."
            exit 1
        fi
    fi

    TMP_DIR=$(mktemp -d)
    trap '[[ -n "${TMP_DIR}" && -d "${TMP_DIR}" ]] && rm -rf "${TMP_DIR}"' EXIT

    ZIP_FILE="$TMP_DIR/terraform.zip"

    curl -fsSL \
        "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip" \
        -o "$ZIP_FILE"

    unzip -q "$ZIP_FILE" -d "$TMP_DIR"

    sudo install -m 0755 "$TMP_DIR/terraform" /usr/local/bin/terraform
fi
