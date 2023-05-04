#!/bin/bash
# This script assumes you are running Kali Linux 
echo "This script will attempt to crack the password of a Microsoft Office file"
echo "Make sure your file is in the same directory as this script!"
read -p "Enter the complete file name of the Office document: " OFFICE
timestamp=$(date +%Y-%m-%d_%H-%M-%S)
if [ ! -f "office2john.py" ]; then
    wget https://raw.githubusercontent.com/magnumripper/JohnTheRipper/bleeding-jumbo/run/office2john.py
fi
wordlists=( "/usr/share/nmap/nselib/data/passwords.lst" "/usr/share/dirb/wordlists/common.txt" "/usr/share/dirbuster/wordlists/directory-list-2.3-medium.txt" "/usr/share/set/src/fasttrack/wordlist.txt" "/usr/share/fern-wifi-cracker/extras/wordlists/common.txt" "/usr/share/metasploit-framework/data/wordlists/password.lst" "/usr/share/wordlists/rockyou.txt" "/usr/share/wfuzz/wordlist/general/common.txt" )
for wordlist in "${wordlists[@]}"; do
    if [ -f "$wordlist" ]; then
        echo "Using wordlist: $wordlist"
        python office2john.py "$OFFICE" > "office_hash_${timestamp}.txt"
        cat "office_hash_${timestamp}.txt" | john --wordlist="$wordlist" --format=office --pot="john.pot" --stdin
        password=$(john --show "office_hash_${timestamp}.txt" | cut -d: -f2)
        if [ ! -z "$password" ]; then
            echo "Password found: $password"
            exit 0
        fi
    else
        echo "Wordlist $wordlist not found. Skipping..."
    fi
done
echo "Password not found..."
