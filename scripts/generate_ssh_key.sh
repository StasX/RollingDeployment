#!/bin/bash
set -e

KEY_DIR="./keys"
KEY_NAME="${PROJECT_NAME}-key"

mkdir -p ${KEY_DIR}

if [ ! -f "${KEY_DIR}/${KEY_NAME}" ]; then
  ssh-keygen -t rsa -b 4096 \
    -f ${KEY_DIR}/${KEY_NAME} \
    -N ""
  chmod 600 ${KEY_DIR}/${KEY_NAME}
fi

if [ ! -f "./keys/${PROJECT_NAME}-key.pem" ]; then
  mv ./keys/${PROJECT_NAME}-key ./keys/${PROJECT_NAME}-key.pem
fi

echo "SSH key pair generated at ${KEY_DIR}/${KEY_NAME}.pem and ${KEY_DIR}/${KEY_NAME}.pub"
