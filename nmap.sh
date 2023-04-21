#!/bin/bash

# Check to see if nmap is installed
# If not installed, then install
if [ $(dpkg-query -W -f='${Status}' nmap 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "The required packages are not installed. Installing required packages now."
  nmap;
  apt install nmap -y
  echo "Required packages have successfully been installed."
fi

# Collect details from user
read -p "Enter Project Name: " PROJECT
read -p "Enter Target IP/Host: " TARGET
read -p "Ports (1-65535): " PORTS
read -p "Verbose (y/n): " VERBOSE
read -p "Aggressive (y/n): " AGGRESSIVE
# read -p "Scripts (default,safe,not intrusive,banner,vuln,http-*): " SCRIPTOPTIONS
TIMESTAMP=`date +"%m-%d-%Y_%T"`
OUTPUT=${PROJECT}_nmap_results_${TIMESTAMP}

# Checking options for verbose usage
if [[ ${VERBOSE^^} = 'Y' || ${VERBOSE^^} = 'YES' ]];
then
    VERBOSE="-v"
else
    VERBOSE=''
fi

# Checking options for aggressive usage
if [[ ${AGGRESSIVE^^} = 'Y' || ${AGGRESSIVE^^} = 'YES' ]];
then
    AGGRESSIVE="-A"
else
    AGGRESSIVE=''
fi

sudo nmap ${TARGET} -p${PORTS} ${VERBOSE} ${AGGRESSIVE} -sC -sV -oX ${OUTPUT}.xml

echo "Converting results to HTML."
xsltproc ${OUTPUT}.xml -o ${OUTPUT}.html

echo "Opening results in Firefox."
firefox ${OUTPUT}.html
