#!/bin/bash

# Source the pretty print functions
source scripts/functions/utils.sh

function shell_intergrate() {
    if ! command -v fzf &>/dev/null; then
        print_error "fzf command not found, cannot integrate with shells."
        exit 1
    fi

    print_info "Integrating fzf with shells..."
    # bash
    eval "$(fzf --bash)"
    # zsh
    if command -v zsh &>/dev/null; then
        print_info "Integrating with zsh..."
        source <(fzf --zsh)
    fi
    # fish
    if command -v fish &>/dev/null; then
        print_info "Integrating with fish..."
        fzf --fish | source
    fi
    print_success "Shell integration completed."
}

# Install fzf if not already installed
if ! command -v fzf &>/dev/null; then
    if ! confirm "fzf not found. Installing fzf"; then
        print_warning "Skipping fzf installation."
        exit 0
    else
        print_info "Installing fzf..."
        # archlinux
        if command -v pacman &>/dev/null; then
            print_info "Installing fzf via pacman..."
            sudo pacman -Syu fzf || {
                print_error "Failed to install fzf using pacman."
                exit 1
            }
            shell_intergrate
        # brew
        elif command -v brew &>/dev/null; then
            print_info "Installing fzf via Homebrew..."
            brew install fzf || {
                print_error "Failed to install fzf using Homebrew."
                exit 1
            }
            shell_intergrate
        # git (fallback method)
        elif command -v git &>/dev/null; then
            print_info "Installing fzf from GitHub repository..."
            git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf || {
                print_error "Failed to clone fzf repository."
                exit 1
            }
            print_info "Running fzf installer..."
            ~/.fzf/install || {
                print_error "fzf installation failed."
                exit 1
            }
            print_success "fzf installed successfully from GitHub."
        else
            print_error "No suitable installation method found for fzf."
            exit 1
        fi
    fi
else
    print_info "fzf is already installed."
fi

print_success "fzf setup completed."
