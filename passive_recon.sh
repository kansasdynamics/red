#!/bin/bash

# This script will run many tools simultaneously to perform passive recon on a target.

# Tools to install, wafw00f, sublist3r, theHarvester
if [ $(dpkg-query -W -f='${Status}' wafw00f 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "The required packages are not installed. Installing required packages now."
  nmap;
  apt install gobuster -y
  echo "Required packages have successfully been installed."
fi

read -p "Target domain (example.com): " TARGET

# Tools to use for output
# host, curl robots.txt, whatweb, whois, dnsrecon -d, wafw00f, theHarvester -d domain.com -b source, 
# Target is not using FQDN, just domain.com
