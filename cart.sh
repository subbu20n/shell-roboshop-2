#!/bin/bash

source ./common.sh
app_setup
nodejs_setup
check_root
systemd_setup

print_time | tee -a $LOG_FILE