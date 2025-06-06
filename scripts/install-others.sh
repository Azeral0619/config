#!/bin/bash

source scripts/functions/utils.sh

# check cuda is installed (/usr/local)
available_cuda_paths=("/usr/local/cuda*" "$HOME/local/cuda*" "/opt/cuda*")
mapfile -t available_cuda_paths < <(get_valid_paths "${available_cuda_paths[@]}")

if [ ${#available_cuda_paths[@]} -eq 0 ]; then
    print_warning "No CUDA installation found."
    CUDA_HOME=""
else
    # shellcheck disable=SC2068
    CUDA_HOME=$(choice_from_array ${available_cuda_paths[@]})
    print_info "Selected CUDA installation: $CUDA_HOME"
fi

#check tensorrt is installed (/usr/local/tensorrt*、~/local/tensorrt*、/opt/tensorrt*)
available_tensorrt_paths=("/usr/local/TensorRT*" "$HOME/local/TensorRT*" "/opt/TensorRT*")
mapfile -t available_tensorrt_paths < <(get_valid_paths "${available_tensorrt_paths[@]}")
if [ ${#available_tensorrt_paths[@]} -eq 0 ]; then
    print_warning "No TensorRT installation found."
    TENSORRT_HOME=""
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
