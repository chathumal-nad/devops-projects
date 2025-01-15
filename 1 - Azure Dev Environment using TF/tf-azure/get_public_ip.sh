#!/bin/bash

# Fetch the IP address
ip_address=$(curl -s https://api64.ipify.org?format=text)

# Output as JSON
echo "{\"ip_address\": \"$ip_address\"}"
