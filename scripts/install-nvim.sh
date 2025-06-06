#!/bin/bash

# Source the pretty print functions
source scripts/functions/utils.sh

# check nvim is installed (/usr/local/nvim*、~/local/nvim*、/opt/nvim*)
available_nvim_paths=("/usr/local/nvim*" "$HOME/local/nvim*" "/opt/nvim*")
mapfile -t available_nvim_paths < <(get_valid_paths "${available_nvim_paths[@]}")
if [[ ${#available_nvim_paths[@]} -eq 0 ]]; then
    if [[ -e "/usr/bin/nvim" ]]; then
        NVIM_HOME="/usr/bin"
    else
        NVIM_HOME=""
    fi
else
    # shellcheck disable=SC2068
    NVIM_HOME=$(choice_from_array ${available_nvim_paths[@]})
    print_info "Selected Neovim installation: $NVIM_HOME"
fi

# Install nvim if not already installed
if [[ -z "$NVIM_HOME" ]]; then
    if ! confirm "Neovim not found. Installing Neovim"; then
        print_warning "Skipping Neovim installation."
        exit 0
    else
        if confirm_no "Use package manager to install Neovim"; then
            print_info "Preparing to download Neovim..."
            arch=$(uname -m)
            os=$(uname -s | tr '[:upper:]' '[:lower:]')
            url="https://github.com/neovim/neovim/releases/latest/download/nvim-${os}-${arch}.tar.gz"
            print_info "Downloading Neovim from ${url}"
            wget "$url" -O /tmp/nvim.tar.gz || {
                print_error "Failed to download nvim from ${url}. Please install nvim manually."
                exit 1
            }
            print_info "Enter the installation path for nvim (default: /opt/nvim):"
            read -r nvim_path
            if [ -z "$nvim_path" ]; then
                nvim_path="/opt/nvim"
            fi

            print_info "Creating installation directory..."
            eval "$(judge_permission "$nvim_path")" mkdir -p "$nvim_path"

            print_info "Extracting Neovim..."
            eval "$(judge_permission "$nvim_path")" tar -xzf /tmp/nvim.tar.gz -C "$nvim_path" || {
                print_error "Failed to extract nvim. Please install nvim manually."
                exit 1
            }
            print_info "Cleaning up temporary files..."
            rm -f /tmp/nvim.tar.gz

            eval "$(judge_permission "$nvim_path")" mv "$(dirname "$nvim_path")/nvim-${os}-${arch}" "$nvim_path" || {
                print_error "Rename Failed. Nvim is installed at $(dirname "$nvim_path")/nvim-${os}-${arch}/"
                exit 1
            }

            print_success "Neovim installed successfully at $nvim_path."
        else
            # apt
            if command -v apt-get &>/dev/null; then
                print_info "Updating package lists..."
                sudo apt-get update
                print_info "Installing Neovim via apt..."
                sudo apt-get install -y neovim || {
                    print_error "Failed to install Neovim via apt."
                    exit 1
                }
            # pacman
            elif command -v pacman &>/dev/null; then
                print_info "Installing Neovim via pacman..."
                sudo pacman -Syu neovim || {
                    print_error "Failed to install Neovim via pacman."
                    exit 1
                }
            # others
            else
                print_error "Unsupported package manager. Please install Neovim manually."
                exit 1
            fi
        fi
    fi
fi

# Copy Neovim configuration files
NVIM_CONFIG_DIR="nvim"
NVIM_TARGET_CONFIG_DIR="$HOME/.config/nvim"
if [ ! -d "$NVIM_TARGET_CONFIG_DIR" ]; then
    print_info "Creating Neovim configuration directory..."
    mkdir -p "$NVIM_TARGET_CONFIG_DIR"
fi
# Copy Config File
print_info "Copying Neovim configuration files..."
rsync -a "$NVIM_CONFIG_DIR/" "$NVIM_TARGET_CONFIG_DIR/"

if [[ -n "$NVIM_HOME" ]] && [[ "$NVIM_HOME" != "/usr/bin" ]]; then
    # TODO: bash
    # fish
    print_info "Setting up Neovim environment variables..."
    echo "set -x PATH $NVIM_HOME/bin "'$PATH'"" >~/.config/fish/conf.d/nvim.fish
    print_success "Neovim environment variables configured."
fi

# Final success message
print_success "Neovim setup completed."
