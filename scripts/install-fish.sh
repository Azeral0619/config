#!/bin/bash

# Source the pretty print functions
source scripts/functions/pretty_print.sh

# Install Fish shell if not already installed
if ! command -v fish &>/dev/null; then
    print_info "Fish shell not found. Installing Fish shell (Y/n)"
    read -r answer
    if [[ -n "$answer" && ! "$answer" =~ ^[Yy]$ ]]; then
        print_warning "Skipping Fish shell installation."
        exit 0
    else
        print_info "Use package manager to install Fish shell (Y/n)"
        read -r answer
        if [[ -n "$answer" && ! "$answer" =~ ^[Yy]$ ]]; then
            print_error "UnImplemented installation method. Please install Fish shell manually."
            exit 1
        else
            # apt
            if command -v apt-get &>/dev/null; then
                print_info "Adding Fish shell repository..."
                sudo add-apt-repository ppa:fish-shell/release-4
                # PPA Mirror https://ppa.launchpadcontent.net https://launchpad.proxy.ustclug.org

                ./bin/ppa-mirror /etc/apt/sources.list.d/fish-shell-ubuntu-release-4-*.list

                print_info "Updating package lists..."
                sudo apt-get update
                print_info "Installing Fish shell..."
                sudo apt-get install -y fish
            # pacman
            elif command -v pacman &>/dev/null; then
                print_info "Installing Fish shell via pacman..."
                sudo pacman -Syu fish
            # homebrew
            elif command -v brew &>/dev/null; then
                print_info "Installing Fish shell via Homebrew..."
                brew install fish
            # others
            else
                print_error "Unsupported package manager. Please install Fish shell manually."
                exit 1
            fi
        fi
    fi
fi

FISH_CONFIG_DIR="fish"
FISH_TARGET_CONFIG_DIR="$HOME/.config/fish"
if [ ! -d "$FISH_TARGET_CONFIG_DIR" ]; then
    print_info "Creating Fish configuration directory..."
    mkdir -p "$FISH_TARGET_CONFIG_DIR"
fi

# Copy Config File
print_info "Copying Fish configuration files..."
rsync -a "$FISH_CONFIG_DIR/" "$FISH_TARGET_CONFIG_DIR/"
print_success "Fish configuration completed."
