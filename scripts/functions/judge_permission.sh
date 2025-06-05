#!/bin/bash

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
