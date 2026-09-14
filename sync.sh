#!/bin/bash
set -e

REPO_URL="https://github.com/ARK-OS-Swift-and-Linux/main.git"
DIR_NAME="ARK-OS"

echo "========================================"
echo "          ARK-OS Sync Script            "
echo "========================================"
echo ""
echo "Syncing the ARK-OS repository and all nested submodules..."

# The --recursive flag automatically clones the repository and all of its 
# submodules, including nested submodules (submodules of submodules) recursively.
git clone --recursive "$REPO_URL" "$DIR_NAME"

echo ""
echo "========================================"
echo "      Successfully synced ARK-OS!"
echo "========================================"
echo "You can now enter the directory and begin building:"
echo "  cd $DIR_NAME"
echo ""
