#!/bin/bash

# Source the pretty print functions
source scripts/functions/utils.sh

available_conda_paths=("$HOME/miniconda3" "$HOME/miniconda" "/opt/miniconda3" "/opt/miniconda" "$HOME/anaconda3" "$HOME/anaconda" "/opt/anaconda3" "/opt/anaconda" "/usr/local/miniconda3" "/usr/local/miniconda" "/usr/local/anaconda3" "/usr/local/anaconda")
mapfile -t available_conda_paths < <(get_valid_paths "${available_conda_paths[@]}")
if [ ${#available_conda_paths[@]} -eq 0 ]; then
    CONDA_HOME=""
else
    # shellcheck disable=SC2068
    CONDA_HOME=$(choice_from_array ${available_conda_paths[@]})
    print_info "Selected Conda installation: $CONDA_HOME"
fi
if [ -z "$CONDA_HOME" ]; then
    # Install Miniconda if not already installed
    if ! confirm "Conda not found. Installing MiniConda"; then
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

        eval "$(judge_permission "$conda_path")" bash /tmp/miniconda.sh -b -u -p "$conda_path" || {
            print_error "Miniconda installation failed."
            exit 1
        }

        rm /tmp/miniconda.sh
        print_success "Miniconda installed successfully."
        CONDA_HOME="$conda_path"
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

if [[ -n "$CONDA_HOME" ]]; then
    # TODO: bash
    # fish
    print_info "Setting up Conda environment variables..."
    eval "$CONDA_HOME/bin/conda init fish" || {
        print_error "Failed to initialize Conda for Fish shell. Please check your Conda installation."
        exit 1
    }
fi
