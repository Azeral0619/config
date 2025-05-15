#!/bin/bash
pkgs=(
    bat
    du-dust
    fd-find
    git-delta
    tokei
    tealdeer
)

for pkg in "${pkgs[@]}"; do
    echo "Installing $pkg..."
    cargo install "$pkg"
done
