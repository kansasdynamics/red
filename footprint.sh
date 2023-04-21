#!/bin/bash

# Check to see if jq is installed
# If not installed, then install
if [ $(dpkg-query -W -f='${Status}' jq 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "The required packages are not installed. Installing required packages now."
  nmap;
  sudo apt install jq -y
  echo "Required packages have successfully been installed."
fi

# Collect details from user
read -p "Enter target domain (example.com): " DOMAIN
read -p "Enter Shodan API key: " SHODAN_API_KEY
shodan init ${SHODAN_API_KEY}

# Make the log file
TIMESTAMP=`date +"%m-%d-%Y_%T"`
OUTPUT=${DOMAIN}_footprint_${TIMESTAMP}.log
touch ${OUTPUT}
echo "Creating ${OUTPUT}."

# Retrieve SSL certificate information
echo "###########################" >> ${OUTPUT}
echo "##### SSL Certificate #####" >> ${OUTPUT}
echo "###########################" >> ${OUTPUT}
curl -s https://crt.sh/\?q\=${DOMAIN}\&output\=json | jq . >> ${OUTPUT}
echo "Retrieving SSL certificate information."

# Retrieve subdomains
echo "###########################" >> ${OUTPUT}
echo "######## Subdomains #######" >> ${OUTPUT}
echo "###########################" >> ${OUTPUT}
curl -s https://crt.sh/\?q\=${DOMAIN}\&output\=json | jq . | grep name | cut -d":" -f2 | grep -v "CN=" | cut -d'"' -f2 | awk '{gsub(/\\n/,"\n");}1;' | sort -u >> temp_subdomain.log
curl -s https://crt.sh/\?q\=${DOMAIN}\&output\=json | jq . | grep name | cut -d":" -f2 | grep -v "CN=" | cut -d'"' -f2 | awk '{gsub(/\\n/,"\n");}1;' | sort -u >> ${OUTPUT}

echo "Retrieving subdomains."

# Retrieve company hosted servers
echo "###########################" >> ${OUTPUT}
echo "##### Company Servers #####" >> ${OUTPUT}
echo "###########################" >> ${OUTPUT}
for i in $(cat temp_subdomain.log);do host $i | grep "has address" | grep ${DOMAIN} | cut -d" " -f1,4 >> ${OUTPUT};done 
echo "Retrieving company hosted servers."

# Shodan IP List
echo "###########################" >> ${OUTPUT}
echo "###### Shodan IP List #####" >> ${OUTPUT}
echo "###########################" >> ${OUTPUT}
for i in $(cat temp_subdomain.log);do host $i | grep "has address" | grep ${DOMAIN} | cut -d" " -f4 >> temp_ip.log;done
for i in $(cat temp_subdomain.log);do host $i | grep "has address" | grep ${DOMAIN} | cut -d" " -f4 >> ${OUTPUT};done
for i in $(cat temp_ip.log);do shodan host $i >> ${OUTPUT};done
echo "Retrieving results from Shodan IP scanning."

# DNS Records
echo "###########################" >> ${OUTPUT}
echo "####### DNS Records #######" >> ${OUTPUT}
echo "###########################" >> ${OUTPUT}
dig any ${DOMAIN} >> ${OUTPUT}
echo "Retrieving DNS records."

# Remove temp_subdomain.log file
rm -f temp_*.log
echo "Cleaning temp files."

echo "Target footprint acquired. See ${OUTPUT} for the results."
