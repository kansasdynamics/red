#!/bin/bash
# This script assumes you are running Kali Linux
echo "This script runs theHarvester against many sources automatically for information gathering"
timestamp=$(date +%Y-%m-%d_%H-%M-%S)
# Define the array with the sources
sources=("baidu" "bufferoverun" "crtsh" "hackertarget" "otx" "projectdiscovery" "rapiddns" "sublist3r" "threatcrowd" "trello" "urlscan" "vhost" "virustotal" "zoomeye")
# Define the target
read -p "Enter target website (example.com): " TARGET
# Function to call theHarvester for each source
harvest() {
  for source in "${sources[@]}"
  do
    theHarvester -d "${TARGET}" -b $source -f "${source}_${TARGET}_${timestamp}"
  done
}
# Call the function
harvest
# Extract all the subdomains and sort
cat *.json | jq -r '.hosts[]' 2>/dev/null | cut -d':' -f 1 | sort -u > "${TARGET}_theHarvester_${timestamp}.txt"
# Merge all passive reconnaissance files
cat ${TARGET}_*_${timestamp}.txt | sort -u > ${TARGET}_subdomains_passive_${timestamp}.txt
cat ${TARGET}_subdomains_passive_${timestamp}.txt | wc -l
# Function to clean up the source files
clean_up() {
  TARGET_CLEAN=${TARGET%%.*}
  echo "Cleaning up files for target: ${TARGET_CLEAN}"
  for source in "${sources[@]}"
  do
    echo "Removing ${source}_${TARGET_CLEAN}.json"
    rm -f "${source}_${TARGET_CLEAN}.json"
    echo "Removing ${source}_${TARGET_CLEAN}.xml"
    rm -f "${source}_${TARGET_CLEAN}.xml"
  done
}
# Call the function
clean_up
