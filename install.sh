#!/bin/bash

# Source the pretty print functions
source scripts/functions/utils.sh

scripts=(
	"install-fish.sh"
	"install-conda.sh"
	"install-fzf.sh"
	"install-go.sh"
	"install-nvim.sh"
	"install-cargo.sh"
	"install-git.sh"
	"install-node.sh"
	"install-omf.sh"
	"install-pip.sh"
	"install-others.sh"
)

if [ $# -eq 0 ] || [ "$1" == "all" ]; then
	print_info "Executing all installation scripts..."
	for script in "${scripts[@]}"; do
		if [ -f "scripts/$script" ]; then
			print_info "Executing $script..."
			if bash "scripts/$script"; then
				print_success "$script executed successfully"
			else
				print_error "$script execution failed, exit code: $?"
			fi
		else
			print_error "Script $script not found in scripts directory"
		fi
	done
else
	for arg in "$@"; do
		if [[ "$arg" == install-*.sh ]]; then
			script="$arg"
		else
			script="install-${arg}.sh"
		fi

		if [[ " ${scripts[*]} " == *" $script "* ]]; then
			if [ -f "scripts/$script" ]; then
				print_info "Executing $script..."
				if bash "scripts/$script"; then
					print_success "$script executed successfully"
				else
					print_error "$script execution failed, exit code: $?"
				fi
			else
				print_error "Script $script not found in scripts directory"
			fi
		else
			print_warning "Script $script is not in the list of available scripts"
			print_info "Available scripts: ${scripts[*]}"
		fi
	done
fi
