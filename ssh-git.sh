#!/bin/sh

if [ -z "$PKEY" ]; then
    # if PKEY is not specified, run ssh using default keyfile
    ssh ""
else
    ssh -v -i "$PKEY" -F /dev/null -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "$@"
fi
