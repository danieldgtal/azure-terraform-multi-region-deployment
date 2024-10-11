#!/bin/bash

# This script will run terraform validate every 2 minutes in an infinite loop

while true; do
    echo "Running terraform validate..."
    terraform validate
    if [ $? -eq 0 ]; then
        echo "Terraform validation successful!"
    else
        echo "Terraform validation failed!"
    fi
    echo "Waiting for 2 minutes..."
    sleep 120  # Wait for 120 seconds (2 minutes)
done

