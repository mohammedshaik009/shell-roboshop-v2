#!/bin/bash

name=payment
source ./common.sh
check_root
app_setup
java_setup
systemd_setup
app_restart
total_time