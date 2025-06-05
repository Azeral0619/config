#!/bin/bash

# Source the pretty print functions
source scripts/functions/pretty_print.sh

# Install Node.js if not already installed
if ! command -v node &>/dev/null; then
    print_info "Node.js not found. Installing Node.js (Y/n)"
    read -r answer
    if [[ -n "$answer" && ! "$answer" =~ ^[Yy]$ ]]; then
        print_warning "Skipping Node.js installation."
        exit 0
    else
        print_info "Installing Node.js..."

        # is macos
        if [[ "$(uname)" == "Darwin" ]]; then
            if command -v brew &>/dev/null; then
                print_info "Installing Node.js via Homebrew..."
                brew install node || {
                    print_error "Node.js installation failed."
                    exit 1
                }
            else
                print_error "Homebrew is not installed. Please install Homebrew first."
                exit 1
            fi
            print_success "Node.js has been installed successfully."
            exit 0
        fi

        # is arch linux
        if command -v pacman &>/dev/null; then
            print_info "Installing Node.js via pacman..."
            sudo pacman -Syu nodejs npm || {
                print_error "Node.js installation failed."
                exit 1
            }
            print_success "Node.js has been installed successfully."
            exit 0
        fi

        if ! command -v fish &>/dev/null; then
            print_error "Fish shell is not installed. Please install Fish shell first."
            exit 1
        fi

        print_info "Installing Node.js LTS version with nvm..."
        fish -c "set nvm_mirror https://npmmirror.com/mirrors/node/; nvm install lts" || {
            print_error "Node.js installation failed."
            exit 1
        }

        print_success "Node.js has been installed successfully."
    fi
else
    print_info "Node.js is already installed."
fi

# Copy Config File
NPM_CONFIG_FILE="npm/.npmrc"
NPM_TARGET_CONFIG_DIR="$HOME"
if [ ! -d "$NPM_TARGET_CONFIG_DIR" ]; then
    print_info "Creating npm configuration directory..."
    mkdir -p "$NPM_TARGET_CONFIG_DIR"
fi
print_info "Copying npm configuration file..."
rsync -a "$NPM_CONFIG_FILE" "$NPM_TARGET_CONFIG_DIR/"
print_success "npm configuration completed."
