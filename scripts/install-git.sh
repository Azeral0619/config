#!/bin/bash

# Source the pretty print functions
source scripts/functions/utils.sh

# Install Git if not already installed
if ! command -v git &>/dev/null; then
    if ! confirm "Git not found. Installing Git"; then
        print_warning "Skipping Git installation."
        exit 0
    else
        # apt
        if command -v apt-get &>/dev/null; then
            print_info "Updating package lists..."
            sudo apt-get update
            print_info "Installing Git via apt..."
            sudo apt-get install -y git || {
                print_error "Failed to install Git."
                exit 1
            }
        # pacman
        elif command -v pacman &>/dev/null; then
            print_info "Installing Git via pacman..."
            sudo pacman -Syu git || {
                print_error "Failed to install Git."
                exit 1
            }
        # homebrew
        elif command -v brew &>/dev/null; then
            print_info "Installing Git via Homebrew..."
            brew install git || {
                print_error "Failed to install Git."
                exit 1
            }
        # others
        else
            print_error "Unsupported package manager. Please install Git manually."
            exit 1
        fi

        print_success "Git installed successfully."
    fi
fi

GIT_CONFIG_FILE="git/.gitconfig"
GIT_TARGET_CONFIG_DIR="$HOME"
if [ ! -d "$GIT_TARGET_CONFIG_DIR" ]; then
    print_info "Creating Git configuration directory..."
    mkdir -p "$GIT_TARGET_CONFIG_DIR"
fi
# Copy Config File
print_info "Copying Git configuration file..."
rsync -a "$GIT_CONFIG_FILE" "$GIT_TARGET_CONFIG_DIR/"
print_success "Git configuration completed."
