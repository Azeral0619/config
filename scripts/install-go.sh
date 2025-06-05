#!/bin/bash

# Source the pretty print functions
source scripts/functions/pretty_print.sh

# Install GO if not already installed
if ! command -v go &>/dev/null; then
    print_info "Go not found. Installing Go (Y/n)"
    read -r answer
    if [[ -n "$answer" && ! "$answer" =~ ^[Yy]$ ]]; then
        print_warning "Skipping Go installation."
        exit 0
    else
        source scripts/functions/judge_permission.sh
        print_info "Installing Go..."
        url_prefix="https://go.dev/dl/"

        print_info "Fetching latest Go version..."
        version=$(wget -qO- https://go.dev/VERSION?m=text | head -n 1) || {
            print_error "Failed to fetch Go version."
            exit 1
        }
        print_info "Latest Go version: $version"

        OS=$(uname -s | tr '[:upper:]' '[:lower:]')
        ARCH=$(uname -m)

        case "$OS" in
        linux)
            if [ "$ARCH" = "x86_64" ]; then
                file_suffix="linux-amd64.tar.gz"
            elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
                print_error "Unsupported prebuilt package for ARM64 architecture."
                exit 1
            else
                print_error "Unsupported architecture: $ARCH"
                exit 1
            fi
            ;;
        darwin)
            if [ "$ARCH" = "x86_64" ]; then
                file_suffix="darwin-amd64.pkg"
            elif [ "$ARCH" = "arm64" ]; then
                file_suffix="darwin-arm64.pkg"
            else
                print_error "Unsupported architecture: $ARCH"
                exit 1
            fi
            ;;
        *)
            print_error "Unsupported operating system: $OS"
            exit 1
            ;;
        esac

        download_url="${url_prefix}${version}.${file_suffix}"
        print_info "Downloading Go from: $download_url"

        if [[ "$file_suffix" == *".pkg" ]]; then
            installer_file="/tmp/go.pkg"
        else
            installer_file="/tmp/go.tar.gz"
        fi

        wget "$download_url" -O "$installer_file" || {
            print_error "Failed to download Go installer from $download_url."
            exit 1
        }

        if [[ "$file_suffix" == *".tar.gz" ]]; then
            print_info "Enter the installation path for Go (default: /usr/local/go):"
            read -r go_path
            if [ -z "$go_path" ]; then
                go_path="/usr/local/go"
            fi

            print_info "Creating directory structure..."
            mkdir -p "$(dirname "$go_path")"

            print_info "Extracting Go installation package..."
            eval "$(judge_permission "$go_path")" tar -C "$(dirname "$go_path")" -xzf "$installer_file" || {
                print_error "Go installation failed."
                exit 1
            }

        elif [[ "$file_suffix" == *".pkg" ]]; then
            go_path="/usr/local/go"
            print_info "Installing Go pkg package to the default location: $go_path"

            eval "$(judge_permission "/usr/local")" installer -pkg "$installer_file" -target / || {
                print_error "Go installation failed."
                exit 1
            }

        fi

        # Clean up downloaded files
        print_info "Cleaning up temporary files..."
        rm -f "$installer_file"
        print_success "Go $version has been installed to $go_path"

        # Configure Go Environment
        print_info "Configuring Go environment variables..."
        "$go_path/bin/go" env -w GO111MODULE=on || print_warning "Failed to set GO111MODULE"
        "$go_path/bin/go" env -w GOPROXY=https://goproxy.cn,direct || print_warning "Failed to set GOPROXY"
        print_success "Go environment configured successfully."
    fi
else
    print_info "Go is already installed."
fi

print_success "Go setup completed."
