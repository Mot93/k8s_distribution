#!/bin/bash

# set -eu # Exit immediately if any command fails or if an unset variable is used
set -e # Exit immediately if any command fails

# Logs passed level and message
# A third argument can be passed as the path to the file where to store logs 
log() {
    if [ ! $# -ge 2 ]; then
        echo "ERROR: 2 argument are required: <level> <message>"
        exit 1
    fi
    # Get level, message and file where to store
    local level=$1
    local message=$2
    # Config logs
    local timestamp=$(date +'%Y-%m-%d %H:%M:%S')
    local log_entry="[$timestamp] [$level] $message"

    # Color config
    # Define colors
    local LIGHT_BLUE='\033[0;34m'
    local YELLOW='\033[0;33m'
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local LIGHT_PURPLE='\033[0;35m'
    local NC='\033[0m' # No Color

    # Print to console with color
    case $level in
        "INFO")
            echo -e "${LIGHT_BLUE}$log_entry${NC}"
            ;;
        "WARNING")
            echo -e "${YELLOW}$log_entry${NC}"
            ;;
        "ERROR")
            echo -e "${RED}$log_entry${NC}"
            ;;
        "SUCCESS")
            echo -e "${GREEN}$log_entry${NC}"
            ;;
        *)
            echo -e "${LIGHT_PURPLE}$log_entry${NC}"
            ;;
    esac

    # Record the log into a file only if a third argument containing the path to the log has been passed
    # if [ ! $# -ge 3 ]; then
    #     local log_file=$3
    #     echo $log_file
    #     # Create directories if they don't exists
    #     mkdir -p "$(dirname "$log_file")"
    #     # Print to log to the specified file (no color)
    #     echo "$log_entry" >> "$log_file"
    # fi
}

log_file_name() {
    if [ ! $# -ge 1 ]; then
        echo "ERROR: 1 argument is required: <name>"
        exit 1
    else
        local file_name="$1"
    fi
    local timestamp=$(date +"%Y-%m-%d")
    echo "${file_name}_${timestamp}.log"
}

export -f log log_file_name

test() {
    # Config
    log_file=$(log_file_name "test")
    # Logs
    log "INFO" "Logging into the file $log_file" $log_file
    log "WARNING" "This log won't be recorded anywhere"
    log "ERROR" "It's RED!"
    log "SUCCESS" "Youy made it 😎"
    log "CUSTOM" "We are going off road!! 🚧"
}
