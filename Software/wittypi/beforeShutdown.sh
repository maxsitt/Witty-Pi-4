#!/bin/bash
# file: beforeShutdown.sh
#
# This script will be executed after Witty Pi receives shutdown command (GPIO-4 gets pulled down).
# If you want to run your commands before turnning of your Raspberry Pi, you can place them here.
# Raspberry Pi will not shutdown until all commands here are executed.
#
# Remarks: please use absolute path of the command, or it can not be found (by root user).
# Remarks: you may append '&' at the end of command to avoid blocking the main daemon.sh.
#
# Includes modifications from https://github.com/maxsitt/Witty-Pi-4

MAX_WAIT=15
COUNTER=0

if /usr/bin/pgrep python3 >/dev/null; then
    # Send SIGTERM signal to all running python3 processes (graceful termination)
    /usr/bin/killall -15 python3

    # Wait for processes to terminate with timeout
    while /usr/bin/pgrep python3 >/dev/null; do
        /usr/bin/sleep 1
        ((COUNTER++))

        # Send SIGKILL signal if timeout reached (force termination)
        if [ $COUNTER -ge $MAX_WAIT ]; then
            /usr/bin/killall -9 python3
            break
        fi
    done
fi
