#!/bin/bash

# Use grep to find the lines containing @env (without line numbers)
grep_output=$(grep -rw "src" -e "@env")

# Extract environment variables using sed to match the desired pattern
env_vars=$(echo "$grep_output" | sed -n 's/.*import { \(.*\) } from.*/\1/p')

# Clean up the list by removing unnecessary spaces and newlines
cleaned_env_vars=$(echo "$env_vars" | tr ',' '\n' | awk '{$1=$1; print}' | sort | uniq)

if [ ! -z "$cleaned_env_vars" ]; then
    echo "Environment variables found in the source code:"
    # Path to your .env file
    env_file=".env"

    # Check if the .env file exists
    if [ -f "$env_file" ]; then
        for var in $(echo "$cleaned_env_vars"); do
            if grep -q "^${var}=" "$env_file"; then
                # Check if the variable has a non-empty value
                value=$(grep "^${var}=" "$env_file" | cut -d'=' -f2)
                if [ -n "$value" ]; then
                    # Green text for "exists" and has a non-empty value
                    echo -e "$var \033[0;32mexists\033[0m"
                else
                    # Yellow text for "exists but is empty"
                    echo -e "$var \033[0;33mexists but is empty\033[0m"
                    exit 1
                fi
            else
                # Red text for "missing"
                echo -e "$var \033[0;31mmissing\033[0m"
                exit 1
            fi
        done
    else
        # echo ".env file not found!"
        # echo "$1"
    fi
else
    echo "No environment variables found in the source code."
    exit 0
fi
