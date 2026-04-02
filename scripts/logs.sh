#!/bin/bash

set -euo pipefail # Exit immediately if any command fails, if an unset variable is used or if any command in the pipeline fails

# Logs passed level and message
# A third argument can be passed as the path to the file where to store logs 
log() {
	if [ $# -lt 2 ]; then
		echo "ERROR: 2 argument are required: <level> <message>"
		exit 1
	fi
	# Get level, message and file where to store
	local level=$1
	local message=$2
	# Config logs
	local timestamp=$(date +'%Y-%m-%d %H:%M:%S')
	local log_entry="[$timestamp] [$level] $message"

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
			echo -e "${LIGHT_BLUE}${log_entry}${NC}"
			;;
		"WARNING")
			echo -e "${YELLOW}${log_entry}${NC}"
			;;
		"ERROR")
			echo -e "${RED}${log_entry}${NC}" >&2 # Prints to stderr
			;;
		"SUCCESS")
			echo -e "${GREEN}${log_entry}${NC}"
			;;
		*)
			echo -e "${LIGHT_PURPLE}${log_entry}${NC}"
			;;
	esac

	# Record the log into a file only if a third argument containing the path to the log has been passed
	if [ $# -ge 3 ]; then
		local log_file=$3
		local log_dir=$(dirname $log_file)
		if [ ! -d $log_dir ]; then
			echo "Directory $log_dir does not exists. Provide existing directory to store log file."
			exit 1
		fi
		# Print to log to the specified file (no color)
		echo "$log_entry" >> "$log_file"
	fi
}

# Given a string with a file name retur the name of a log file
log_file_name() {
	if [ $# -lt 1 ]; then
		log "ERROR" "1 argument is required: <name>"
		exit 1
	fi
	local file_name="$1"
	local timestamp=$(date +"%Y-%m-%d")
	echo "${file_name}_${timestamp}.log"
}

# Simplify the usage of the log function
# Before calling these functions, make sure to define log_file
#   log_file must be a valid path to the file where the log has to be stored
#   The directory has to exists but not the file

log_info() {
    if [ -z "${log_file:-}" ]; then
        echo "ERROR: log_file variable not set" >&2
        return 1
    fi
    log "INFO" "$1" "$log_file"
}

log_warning() {
    if [ -z "${log_file:-}" ]; then
        echo "ERROR: log_file variable not set" >&2
        return 1
    fi
    log "WARNING" "$1" "$log_file"
}

log_error() {
    if [ -z "${log_file:-}" ]; then
        echo "ERROR: log_file variable not set" >&2
        return 1
    fi
    log "ERROR" "$1" "$log_file"
}

log_success() {
    if [ -z "${log_file:-}" ]; then
        echo "ERROR: log_file variable not set" >&2
        return 1
    fi
    log "SUCCESS" "$1" "$log_file"
}

# Suite of test for the functions defined in this file
test() {
	# Check if 
	if [ $# -lt 1 ]; then
		echo "ERROR: 1 argument is required: <log dir>"
		exit 1
	fi
	# Config
	log_file="$1/$(log_file_name "test")"
	# Logs
	log "INFO" "Logging into the file $log_file" $log_file
	log "WARNING" "This log won't be recorded anywhere"
	log "ERROR" "It's RED!"
	log "SUCCESS" "You made it 😎"
	log "CUSTOM" "We are going off road!! 🚧"
	log_info "Info logged with log_info ℹ️"
	log_warning "Warning logged with a function ⚠️"
	log_error "Error logged with a function ⛔️"
	log_success "Success logged with a function ✅"
}

export log log_file_name test
