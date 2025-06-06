#!/bin/bash

# Source the pretty print functions
source scripts/functions/utils.sh

# Install Rustup if not already installed
if ! command -v rustup &>/dev/null; then
    if ! confirm "Rustup not found. Installing Rustup"; then
        print_warning "Skipping Rustup installation."
        exit 0
    else
        print_info "Installing Rustup..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh || {
            print_error "Failed to install Rustup. Please install Rustup manually."
            exit 1
        }
    fi
fi

# Ensure Cargo is available in the PATH
if ! command -v cargo &>/dev/null; then
    print_info "Adding Cargo to the PATH..."
    source "$HOME/.cargo/env"
fi

# Mirror for Cargo registry
CARGO_CONFIG_FILE="cargo/config.toml"
CARGO_TARGET_CONFIG_DIR="$HOME/.cargo"
if [ ! -d "$CARGO_TARGET_CONFIG_DIR" ]; then
    mkdir -p "$CARGO_TARGET_CONFIG_DIR"
fi

# Copy Config File
print_info "Copying Cargo configuration file..."
rsync -a $CARGO_CONFIG_FILE "$CARGO_TARGET_CONFIG_DIR/"
print_success "Cargo configuration file copied successfully."

if [[ -e "$HOME/.cargo" ]]; then
    # TODO: bash
    # fish
    print_info "Setting up Cargo environment variables..."
    if [[ -e "$HOME/.cargo/env.fish" ]]; then
        echo "source \"$HOME/.cargo/env.fish\"" >~/.config/fish/conf.d/rustup.fish
    else
        echo "set -x PATH \"$HOME/.cargo/bin\" "'$PATH'"" >~/.config/fish/conf.d/rustup.fish
    fi
    print_success "Cargo environment variables configured."
fi

if ! confirm "Installing Cargo packages"; then
    print_warning "Skipping Cargo package installation."
    exit 0
fi

# Install Cargo packages
pkgs=(
    bat
    du-dust
    fd-find
    git-delta
    tokei
    tealdeer
    zellij # zellij setup --generate-completion fish > ~/.config/fish/completions/zellij.fish
    ripgrep
    sd
    cargo-cache
)

for pkg in "${pkgs[@]}"; do
    print_info "Installing $pkg..."
    if cargo install "$pkg" --locked || cargo install "$pkg"; then
        print_success "$pkg installed successfully."
    else
        print_error "Failed to install $pkg."
    fi
done

print_success "All Cargo packages have been processed."
