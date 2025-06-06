#!/bin/bash

# Source the pretty print functions
source scripts/functions/utils.sh

# Copy Config File
print_info "Setting up pip configuration..."
PIP_CONFIG_FILE="pip/pip.conf"
PIP_TARGET_CONFIG_DIR="$HOME/.pip"
if [ ! -d "$PIP_TARGET_CONFIG_DIR" ]; then
    print_info "Creating pip configuration directory..."
    mkdir -p "$PIP_TARGET_CONFIG_DIR"
fi
# Copy Config File
print_info "Copying pip configuration file..."
rsync -a "$PIP_CONFIG_FILE" "$PIP_TARGET_CONFIG_DIR/"
print_success "pip configuration completed."
