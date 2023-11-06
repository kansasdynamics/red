#!/bin/bash

# This script will run many tools simultaneously to perform passive recon on a target.

if [ $(dpkg-query -W -f='${Status}' wafw00f 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "The required packages are not installed. Installing required packages now."
  nmap;
  apt install gobuster -y
  echo "Required packages have successfully been installed."
fi