#!/bin/bash

error_log() {
    log_file=$1
    log=$2

    # Create the log directory if it doesn't exists
    log_dir=$(dirname -- "$log_file")
    mkdir -p $log_dir

    log_file=$1     
    if [ ! -f $FILE ]; then
        touch $log_file
    fi

    echo $log
    echo $log >> $log_file
}

export -f error_log
