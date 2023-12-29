#!/bin/bash

# Check if the file argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <filename>"
  exit 1
fi

# Generate a timestamp
timestamp=$(date +"%Y%m%d_%H%M%S")

# Check to see if the following tools are installed.
# If not, then install the tools
# apt install libimage-exiftool-perl steghide file hexdump
if [ $(dpkg-query -W -f='${Status}' libimage-exiftool-perl steghide file hexdump 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  apt-get install libimage-exiftool-perl steghide file hexdump;
fi

# Extract the base filename without extension
base_filename=$(basename "$1" | cut -d. -f1)

# Creating the analysis and strings file names
analysis_file="${base_filename}_${timestamp}_Analysis.log"
strings_file="${base_filename}_${timestamp}_Strings.txt"

# Creating the analysis file
touch "$analysis_file"
echo "### File Name ###" >> "$analysis_file"
echo '-----------------' >> "$analysis_file"
echo $1 >> "$analysis_file"
echo >> "$analysis_file"

# Hash
shm_id=$(sha256sum  $1 | awk '{print $1}')
echo "### SHA256 File Hash ###" >> "$analysis_file"
echo '-------------------------' >> "$analysis_file"
echo $shm_id >> "$analysis_file"
echo >> "$analysis_file"

# VirusTotal
echo "### VirusTotal ###" >> "$analysis_file"
echo '------------------' >> "$analysis_file"
echo '[VirusTotal] https://www.virustotal.com/gui/file/'$shm_id'' >> "$analysis_file"
echo >> "$analysis_file"

# Hexdump
echo "### Hexdump ###" >> "$analysis_file"
echo '----------------' >> "$analysis_file"
hexdump -C -n 100 $1 >> "$analysis_file"
echo >> "$analysis_file"

# File
echo "### File Type ###" >> "$analysis_file"
echo '-----------------' >> "$analysis_file"
file -i $1 >> "$analysis_file"
echo >> "$analysis_file"

# Exiftool
echo "### Exiftool ###" >> "$analysis_file"
echo '----------------' >> "$analysis_file"
exiftool $1 >> "$analysis_file"
echo >> "$analysis_file"

# Strings
echo "### Strings Output ###" >> "$analysis_file"
echo '----------------------' >> "$analysis_file"
strings -a $1 > "$strings_file"
echo "Strings output stored in $strings_file" >> "$analysis_file"
echo >> "$analysis_file"
