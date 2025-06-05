#!/bin/bash

# Source the pretty print functions
source scripts/functions/pretty_print.sh

# Install Miniconda if not already installed
if ! command -v conda &>/dev/null; then
    print_info "Conda not found. Installing Miniconda (Y/n)"
    read -r answer
    if [[ -n "$answer" && ! "$answer" =~ ^[Yy]$ ]]; then
        print_warning "Skipping Miniconda installation."
        exit 0
    else
        print_info "Installing Miniconda..."

        wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh || {
            print_error "Failed to download Miniconda installer."
            exit 1
        }

        print_info "Enter the installation path for Miniconda (default: ~/miniconda3):"
        read -r conda_path
        if [ -z "$conda_path" ]; then
            conda_path=~/miniconda3
        fi

        if [ "$(type -t judge_permission)" != function ]; then
            source scripts/functions/judge_permission.sh
        fi

        eval "$(judge_permission "$conda_path")" bash /tmp/miniconda.sh -b -u -p "$conda_path" || {
            print_error "Miniconda installation failed."
            exit 1
        }

        rm /tmp/miniconda.sh
        print_success "Miniconda installed successfully."
    fi
fi

CONDA_CONFIG_FILE="conda/.condarc"
CONDA_TARGET_CONFIG_DIR="$HOME"
if [ ! -d "$CONDA_TARGET_CONFIG_DIR" ]; then
    mkdir -p "$CONDA_TARGET_CONFIG_DIR"
fi
# Copy Config File
print_info "Copying conda configuration file..."
rsync -a "$CONDA_CONFIG_FILE" "$CONDA_TARGET_CONFIG_DIR/"
print_success "Conda configuration completed."
