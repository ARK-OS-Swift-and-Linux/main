#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
# Exit if an uninitialized variable is used
# Fail a pipeline if any command within it fails
set -euo pipefail

# -----------------------------------------------------------------------------
# Colors and Output Helpers
# -----------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
REPO_URL="https://github.com/ARK-OS-Swift-and-Linux/ark-os.git"
REPO_DIR="arkos"
LFS_DIR="system"

# -----------------------------------------------------------------------------
# Dependency Checks
# -----------------------------------------------------------------------------
info "Checking for required dependencies..."

if ! command -v git &> /dev/null; then
    error "git is not installed or not in PATH."
    exit 1
fi

if ! git lfs version &> /dev/null; then
    error "git-lfs is not installed or not initialized."
    echo "Please install Git LFS (e.g., 'sudo apt-get install git-lfs') and run 'git lfs install'."
    exit 1
fi

# -----------------------------------------------------------------------------
# Clone or Sync Main Repository
# -----------------------------------------------------------------------------
if [ -d "$REPO_DIR/.git" ]; then
    info "Repository already exists at $REPO_DIR. Syncing latest changes..."
    pushd "$REPO_DIR" > /dev/null
    git pull --rebase || { 
        error "Failed to pull latest changes. Please resolve conflicts manually."
        popd > /dev/null
        exit 1
    }
else
    info "Cloning repository $REPO_URL into $REPO_DIR..."
    git clone "$REPO_URL" "$REPO_DIR" --depth=1 || {
        error "Failed to clone repository."
        exit 1
    }
    pushd "$REPO_DIR" > /dev/null
fi

# -----------------------------------------------------------------------------
# Submodule Initialization
# -----------------------------------------------------------------------------
info "Initializing and updating submodules recursively..."
git submodule sync --recursive --depth=1
git submodule update --init --recursive --depth=1|| { 
    error "Failed to initialize or update submodules."
    popd > /dev/null
    exit 1
}

# -----------------------------------------------------------------------------
# LFS Pull
# -----------------------------------------------------------------------------
info "Checking for Git LFS directories..."

if [ -d "$LFS_DIR" ]; then
    info "Pulling Git LFS assets for $LFS_DIR..."
    pushd "$LFS_DIR" > /dev/null
    
    # Run lfs pull specifically for this directory
    git lfs pull || { 
        error "Failed to pull Git LFS assets in $LFS_DIR."
        popd > /dev/null
        exit 1
    }
    
    popd > /dev/null
    success "LFS assets pulled successfully."
else
    warn "Directory $LFS_DIR does not exist. Skipping LFS pull."
fi

# Return to original directory
popd > /dev/null

# -----------------------------------------------------------------------------
# Completion
# -----------------------------------------------------------------------------
success "Repository setup is complete! You can now cd into $REPO_DIR."
