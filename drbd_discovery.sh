#!/bin/bash
# /usr/local/bin/drbd_discovery.sh
# chmod +x /usr/local/bin/drbd_discovery.sh

declare -A RESOURCE_MAP

# First, create a map of resource minor numbers to names using drbdadm dump
while IFS=" " read -r resource_name minor_num
do
  if [[ -n "$minor_num" && -n "$resource_name" ]]; then
    RESOURCE_MAP["$minor_num"]="$resource_name"
  fi
done < <(drbdadm dump | awk -F'[ ;]' '/^resource/ {resource_name=$2} /minor/ {print resource_name, $(NF-1)}')

declare -A RESOURCES

# Discover resources from /proc/drbd
while IFS= read -r minor_num
do
  # Use the resource name from RESOURCE_MAP if available, otherwise use "unknown"
  resource_name=${RESOURCE_MAP["$minor_num"]:-unknown}
  RESOURCES["$resource_name:$minor_num"]=1
done < <(awk '/^[ \t]*[0-9]+:/{print $1}' /proc/drbd | sed 's/:$//')

# Build the DATA string for JSON
DATA=""
comma=""
for resource in "${!RESOURCES[@]}"; do
  IFS=: read -r resource_name minor_num <<< "$resource"
  DATA="${DATA}${comma}{
    \"{#DRBD_MINOR_NUM}\":\"${minor_num}\",
    \"{#DRBD_RESOURCE_NAME}\":\"${resource_name}\"
  }"
  comma=","
done

echo -e "{\"data\":[$DATA]}"
