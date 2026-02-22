#!/bin/bash

# Example usage
# log "INFO" "Script started" "log_file.log"

# Log function
log() {
    if [ ! $# -ge 3 ]; then
        echo "ERROR: 3 argument are required: level message log_file"
        exit 1
    fi
    # Get level, message and file where to store
    local level=$1
    local message=$2
    local log_file=$3
    # Config logs
    local timestamp=$(date +'%Y-%m-%d %H:%M:%S')
    local log_entry="[$timestamp] [$level] $message"

    # Color config
    # Define colors
    local RED='\033[0;31m'
    local YELLOW='\033[1;33m'
    local GREEN='\033[0;32m'
    local NC='\033[0m' # No Color

    # Print to console with color
    case $level in
        "INFO")
            echo -e "${GREEN}$log_entry${NC}"
            ;;
        "WARNING")
            echo -e "${YELLOW}$log_entry${NC}"
            ;;
        "ERROR")
            echo -e "${RED}$log_entry${NC}"
            ;;
        *)
            echo -e "$log_entry"
            ;;
    esac

    # Create directories if they don't exist
    mkdir -p "$(dirname "$log_file")"

    # Create the log file if it doesn't exist
    touch "$log_file"

    # Print to log file (no color)
    echo "$log_entry" >> "$log_file"
}

export -f log
