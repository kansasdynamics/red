#!/bin/bash

# Check to see if nmap is installed
# If not installed, then install
if [ $(dpkg-query -W -f='${Status}' hashcat 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "The required packages are not installed. Installing required packages now."
  apt install hashcat -y
  echo "Required packages have successfully been installed."
fi
