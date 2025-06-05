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
