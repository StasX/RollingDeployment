#!/bin/bash
set -e

KEY_DIR="./keys"
KEY_NAME="${PROJECT_NAME}-key"
KEY_PATH="${KEY_DIR}/${KEY_NAME}"
PEM_PATH="${KEY_PATH}.pem"
PUB_PATH="${KEY_PATH}.pub"

mkdir -p "$KEY_DIR"

if [ ! -f "$KEY_PATH" ] && [ ! -f "$PEM_PATH" ]; then
    ssh-keygen -t rsa -b 4096 \
        -f "$KEY_PATH" \
        -N ""
fi

if [ -f "$KEY_PATH" ] && [ ! -f "$PEM_PATH" ]; then
    mv "$KEY_PATH" "$PEM_PATH"
fi

chmod 600 "$PEM_PATH"

echo "SSH key pair available at $PEM_PATH and $PUB_PATH"
