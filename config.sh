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

# test condapath
conda_paths=(
	"$HOME/anaconda3"
	"$HOME/miniconda3"
	"/usr/local/anaconda3"
	"/usr/local/miniconda3"
	"/opt/anaconda3"
	"/opt/miniconda3"
)

available_paths=()

for path in "${conda_paths[@]}"; do
	if [ -d "$path" ]; then
		available_paths+=("$path")
	fi
done

if [ ${#available_paths[@]} -gt 0 ]; then
	echo "Available Conda paths:"
	for i in "${!available_paths[@]}"; do
		echo "$i: ${available_paths[$i]}"
	done

	read -p "Enter the number of your chosen Conda path (default: 0): " choice
	choice=${choice:-0}

	if [ "$choice" -ge 0 ] && [ "$choice" -lt ${#available_paths[@]} ]; then
		conda_path="${available_paths[$choice]}"
		echo "Selected Conda path: $conda_path"
	else
		echo "Invalid choice. Using the first available path."
		conda_path="${available_paths[0]}"
	fi
fi

"$conda_path/bin/conda" init $(basename $SHELL)

echo "Done."
