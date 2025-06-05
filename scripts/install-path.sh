#!/bin/bash

# Source the pretty print functions
source scripts/functions/pretty_print.sh

function get_valid_paths() {
    local valid_paths=()
    local index=0

    for pattern in "$@"; do
        local base_dir
        local name_pattern
        base_dir=$(dirname "$pattern")
        name_pattern=$(basename "$pattern")

        if [[ "$base_dir" == "." ]]; then
            base_dir=$(pwd)
        fi

        while IFS= read -r matched_path; do
            if [[ -n "$matched_path" ]]; then
                valid_paths[index]="$matched_path"
                ((index++))
            fi
        done < <(find "$base_dir" -maxdepth 1 -iname "$name_pattern" 2>/dev/null)
    done

    echo "${valid_paths[@]}"
}

function choice_from_array() {
    if [ $# -eq 0 ]; then
        print_error "No options provided." >&2
        return 1
    elif [ $# -eq 1 ]; then
        echo "$1"
        return 0
    else
        print_info "Available Paths:" >&2
        local idx=0
        # 将所有参数存储到数组中
        local -a options=("$@")

        for i in "$@"; do
            print_info "$idx: $i" >&2
            ((idx++))
        done

        local valid_choice=false
        while [ "$valid_choice" = false ]; do
            print_info "Select a path (default: 0):" >&2
            read -r choice
            if [ -z "$choice" ]; then
                choice=0
                valid_choice=true
            elif [[ "$choice" =~ ^[0-9]+$ ]]; then
                if [ "$choice" -ge 0 ] && [ "$choice" -lt $# ]; then
                    valid_choice=true
                else
                    print_error "Invalid selection. Please choose a number between 0 and $(($# - 1))." >&2
                fi
            else
                print_error "Invalid input. Please enter a valid number." >&2
            fi
        done

        # 输出选定的路径（只有这行会被命令替换捕获）
        echo "${options[$choice]}"
    fi
}

# check cuda is installed (/usr/local)
available_cuda_paths=("/usr/local/cuda*" "$HOME/local/cuda*" "/opt/cuda*")
mapfile -t available_cuda_paths < <(get_valid_paths "${available_cuda_paths[@]}")

if [ ${#available_cuda_paths[@]} -eq 0 ]; then
    print_warning "No CUDA installation found."
    CUDA_HOME=
else
    # shellcheck disable=SC2068
    CUDA_HOME=$(choice_from_array ${available_cuda_paths[@]})
    print_info "Selected CUDA installation: $CUDA_HOME"
fi

# check go is installed (/usr/local/go、~/local/go、/opt/go)
available_go_paths=("/usr/local/go" "$HOME/local/go" "/opt/go")
mapfile -t available_go_paths < <(get_valid_paths "${available_go_paths[@]}")

if [ ${#available_go_paths[@]} -eq 0 ]; then
    print_warning "No Go installation found."
    GO_ROOT=
else
    # shellcheck disable=SC2068
    GO_ROOT=$(choice_from_array ${available_go_paths[@]})
    print_info "Selected Go installation: $GO_ROOT"
fi

# check nvim is installed (/usr/local/nvim*、~/local/nvim*、/opt/nvim*)
available_nvim_paths=("/usr/local/nvim*" "$HOME/local/nvim*" "/opt/nvim*")
mapfile -t available_nvim_paths < <(get_valid_paths "${available_nvim_paths[@]}")
if [ ${#available_nvim_paths[@]} -eq 0 ]; then
    print_warning "No Neovim installation found."
    NVIM_HOME=
else
    # shellcheck disable=SC2068
    NVIM_HOME=$(choice_from_array ${available_nvim_paths[@]})
    print_info "Selected Neovim installation: $NVIM_HOME"
fi

# check cargo is installed
available_cargo_paths=("$HOME/.cargo" "/usr/local/cargo" "/opt/cargo" "$HOME/local/cargo")
mapfile -t available_cargo_paths < <(get_valid_paths "${available_cargo_paths[@]}")
if [ ${#available_cargo_paths[@]} -eq 0 ]; then
    print_warning "No Cargo installation found."
    CARGO_HOME=
else
    # shellcheck disable=SC2068
    CARGO_HOME=$(choice_from_array ${available_cargo_paths[@]})
    print_info "Selected Cargo installation: $CARGO_HOME"
fi

#check tensorrt is installed (/usr/local/tensorrt*、~/local/tensorrt*、/opt/tensorrt*)
available_tensorrt_paths=("/usr/local/TensorRT*" "$HOME/local/TensorRT*" "/opt/TensorRT*")
mapfile -t available_tensorrt_paths < <(get_valid_paths "${available_tensorrt_paths[@]}")
if [ ${#available_tensorrt_paths[@]} -eq 0 ]; then
    print_warning "No TensorRT installation found."
    TENSORRT_HOME=
else
    # shellcheck disable=SC2068
    TENSORRT_HOME=$(choice_from_array ${available_tensorrt_paths[@]})
    print_info "Selected TensorRT installation: $TENSORRT_HOME"
fi

if [[ -n "$CUDA_HOME" ]]; then
    # TODO: bash
    # fish
    print_info "Setting up CUDA environment variables..."
    echo 'set -x CUDA_HOME /usr/local/cuda
set -x PATH $CUDA_HOME/bin $PATH
set -x LD_LIBRARY_PATH $CUDA_HOME/lib64 $LD_LIBRARY_PATH' >~/.config/fish/conf.d/cuda.fish
    print_success "CUDA environment variables configured."
fi

if [[ -n "$GO_ROOT" ]]; then
    # TODO: bash
    # fish
    print_info "Setting up Go environment variables..."
    echo "set -x GOPATH "'$HOME'"/go
set -x GOROOT $GO_ROOT
set -x PATH "'$GO_ROOT'"/bin "'$PATH'"" >~/.config/fish/conf.d/go.fish
    print_success "Go environment variables configured."
fi

if [[ -n "$NVIM_HOME" ]]; then
    # TODO: bash
    # fish
    print_info "Setting up Neovim environment variables..."
    echo "set -x PATH $NVIM_HOME/bin "'$PATH'"" >~/.config/fish/conf.d/nvim.fish
    print_success "Neovim environment variables configured."
fi

if [[ -n "$CARGO_HOME" ]]; then
    # TODO: bash
    # fish
    print_info "Setting up Cargo environment variables..."
    if [[ -e "$CARGO_HOME/env.fish" ]]; then
        echo "source \"$CARGO_HOME/env.fish\"" >~/.config/fish/conf.d/rustup.fish
    else
        echo "set -x PATH \"$CARGO_HOME/bin\" "'$PATH'"" >~/.config/fish/conf.d/rustup.fish
    fi
    print_success "Cargo environment variables configured."
fi

if [[ -n "$TENSORRT_HOME" ]]; then
    # TODO: bash
    # fish
    print_info "Setting up TensorRT environment variables..."
    echo "set -x TENSORRT_HOME $TENSORRT_HOME
set -x PATH "'$TENSORRT_HOME/bin'" "'$PATH'"
set -x LD_LIBRARY_PATH "'$TENSORRT_HOME'"/lib "'$LD_LIBRARY_PATH'"" >~/.config/fish/conf.d/tensorrt.fish
    print_success "TensorRT environment variables configured."
fi

print_success "All environment paths have been configured successfully."
