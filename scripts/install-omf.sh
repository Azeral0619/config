#!/bin/bash

# Source the pretty print functions
source scripts/functions/utils.sh

# Install omf if not already installed
print_info "Installing Oh My Fish..."
if [ -d "$HOME/.local/share/omf" ]; then
    print_info "Oh My Fish is already installed."
else
    print_info "Downloading and installing Oh My Fish..."
    curl -L https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish || {
        print_error "Failed to install Oh My Fish. Please install it manually."
        exit 1
    }
    print_success "Oh My Fish installed successfully."
fi

# Copy Config File
OMF_CONFIG_DIR="omf"
OMF_TARGET_CONFIG_DIR="$HOME/.config/omf"

print_info "Copying Oh My Fish configuration files..."
rsync -a "$OMF_CONFIG_DIR/" "$OMF_TARGET_CONFIG_DIR/"
print_success "Oh My Fish configuration completed."
