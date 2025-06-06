#!/bin/bash

# Define colors and emoji
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Define emoji
EMOJI_SUCCESS="✅"
EMOJI_ERROR="❌"
EMOJI_INFO="ℹ️"
EMOJI_WARNING="⚠️"

# Function: Print informational message
function print_info() {
    echo -e "${BLUE}${EMOJI_INFO} INFO:${NC} $1"
}

# Function: Print success message
function print_success() {
    echo -e "${GREEN}${EMOJI_SUCCESS} SUCCESS:${NC} $1"
}

# Function: Print error message to stderr
function print_error() {
    echo -e "${RED}${EMOJI_ERROR} ERROR:${NC} $1" >&2
}

# Function: Print warning message
function print_warning() {
    echo -e "${YELLOW}${EMOJI_WARNING} WARNING:${NC} $1"
}

function judge_permission() {
    local target_path="$1"
    local action="${2:-write}"
    local check_path=""

    if [ -z "$target_path" ]; then
        return 1
    fi

    target_path=$(realpath -m "$target_path")

    if [ -e "$target_path" ]; then
        check_path="$target_path"
    else
        check_path="$target_path"
        while [ ! -e "$check_path" ] && [ "$check_path" != "/" ]; do
            check_path=$(dirname "$check_path")
        done
    fi

    # 根据操作类型检查权限
    case "$action" in
    "read")
        if [ ! -r "$check_path" ]; then
            echo "sudo"
        fi
        ;;
    "write")
        if [ ! -w "$check_path" ]; then
            echo "sudo"
        fi
        ;;
    "execute")
        if [ ! -x "$check_path" ]; then
            echo "sudo"
        fi
        ;;
    *)
        return 1
        ;;
    esac
    return 0
}

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
            if [[ -n "$matched_path" && -d "$matched_path" ]]; then
                valid_paths[index]="$matched_path"
                ((index++))
            fi
        done < <(find "$base_dir" -maxdepth 1 -iname "$name_pattern" 2>/dev/null)
    done

    if [ ${#valid_paths[@]} -gt 0 ]; then
        printf '%s\n' "${valid_paths[@]}" | sort -ud
    fi
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

function confirm() {
    local prompt="$1"

    if [[ -z "$prompt" ]]; then
        print_error "Prompt cannot be empty."
        return 1
    fi

    while true; do
        print_info "$prompt [Y/n]: "
        read -r answer
        case "${answer,,}" in
        y | yes | "")
            return 0
            ;;
        n | no)
            return 1
            ;;
        *)
            print_error "Invalid input. Please enter 'Y' or 'N'."
            ;;
        esac
    done
}

function confirm_no() {
    local prompt="$1"

    if [[ -z "$prompt" ]]; then
        print_error "Prompt cannot be empty."
        return 1
    fi

    while true; do
        print_info "$prompt [y/N]: "
        read -r answer
        case "${answer,,}" in
        y | yes)
            return 0
            ;;
        n | no | "")
            return 1
            ;;
        *)
            print_error "Invalid input. Please enter 'Y' or 'N'."
            ;;
        esac
    done
}
