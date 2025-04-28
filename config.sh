#!/bin/bash

src_dir="config"
dst_dir="$HOME"

for item in "$src_dir"/.*; do
    if [[ "$item" == "$src_dir/." || "$item" == "$src_dir/.." || "$item" == "$src_dir/.git" ]]; then
        continue
    fi

    base_name=$(basename "$item")

    dst_path="$dst_dir/$base_name"

    if [[ -e "$dst_path" ]]; then
	read -p "File or directory '$dst_path' exists, overwrite?(y/n)" answer
        if [[ "$answer" == [Yy] ]]; then
            rsync -a "$item" "$dst_dir"
        else
            echo "Skip: $dst_path"
        fi
    else
        rsync -a "$item" "$dst_dir"
    fi
done

echo "Done."
