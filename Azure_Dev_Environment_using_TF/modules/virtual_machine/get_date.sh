#!/bin/sh

#fetch date
get_date=$(date '+%m-%dT%H-%M')

# Output as JSON
echo "{\"date\": \"$get_date\"}"