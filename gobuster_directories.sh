#!/bin/bash

# This script provides a user-friendly interface for using gobuster on website directories. 
# This script assumes you are using Kali Linux with the following wordlists available:
# /usr/share/wordlists/dirbuster/

# Check to see if gobuster is installed
# If not installed, then install
if [ $(dpkg-query -W -f='${Status}' gobuster 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "The required packages are not installed. Installing required packages now."
  nmap;
  apt install gobuster -y
  echo "Required packages have successfully been installed."
fi

# Print introductory text
printf "This script provides a user-friendly interface for using gobuster on website directories.\n"
printf "It is designed for use on Kali Linux and assumes the following wordlists are available:\n"
printf "/usr/share/wordlists/dirbuster/\n"
printf "\n"
printf "Please follow the prompts to begin enumerating.\n"
printf "\n"

# Collect user inputs
read -p "Enter Target Host (e.g., http://127.0.0.1): " TARGETHOST
read -p "Enter Website Port (e.g., 80, 443, 8080): " TARGETPORT
TARGETURL="${TARGETHOST}:${TARGETPORT}"
read -p "Output results to file? (Y/N): " OUTPUT
OUTPUT=${OUTPUT^^}

# Print WordList Options
echo "WordList Options:"
printf "\n"
# Define the list header
printf "%-4s %-60s\n" "#" "List"
printf "%-4s %-60s\n" "---" "----"

# Define the list options
printf "%-4d %-60s\n" 0 "Apache User Enum 1.0"
printf "%-4d %-60s\n" 1 "Apache User Enum 2.0"
printf "%-4d %-60s\n" 2 "Directories - jbrofuzz"
printf "%-4d %-60s\n" 3 "Directory List 1.0 Medium"
printf "%-4d %-60s\n" 4 "Directory List 2.3 Small"
printf "%-4d %-60s\n" 5 "Directory List 2.3 Medium"
printf "%-4d %-60s\n" 6 "Directory List 2.3 Small (lowercase)"
printf "%-4d %-60s\n" 7 "Directory List 2.3 Medium (lowercase)"
printf "\n"

# Prompt user for input on WordList
read -p "Select a WordList (0-7): " WORDLIST

# Path to directory containing files
DIR_PATH="/usr/share/wordlists/dirbuster"

# Choose file based on user input
case $WORDLIST in
    0)
        SELECTED_WORDLIST="$DIR_PATH/apache-user-enum-1.0.txt"
        ;;
    1)
        SELECTED_WORDLIST="$DIR_PATH/apache-user-enum-2.0.txt"
        ;;
    2)
        SELECTED_WORDLIST="$DIR_PATH/directories.jbrofuzz"
        ;;
    3)
        SELECTED_WORDLIST="$DIR_PATH/directory-list-1.0.txt"
        ;;
    4)
        SELECTED_WORDLIST="$DIR_PATH/directory-list-2.3-small.txt"
        ;;
    5)
        SELECTED_WORDLIST="$DIR_PATH/directory-list-2.3-medium.txt"
        ;;
    6)
        SELECTED_WORDLIST="$DIR_PATH/directory-list-lowercase-2.3-small.txt"
        ;;
    7)
        SELECTED_WORDLIST="$DIR_PATH/directory-list-lowercase-2.3-medium.txt"
        ;;
    *)
        echo "Invalid option selected."
        exit 1
        ;;
esac

# Showing the filename the user selected
echo "Using file: $SELECTED_WORDLIST"
printf "\n"

if [ "$OUTPUT" == "Y" ]; then
    # Create timestamp and filename structure
    TIMESTAMP=`date +"%m-%d-%Y_%T"`
    FILENAME=${TARGETHOST}_gobuster_results_${TIMESTAMP}.log
    
    # Run gobuster with output to file
    gobuster dir -u "$TARGETURL" -o "$FILENAME" -w "$SELECTED_WORDLIST"
else
    # Run gobuster without output to file
    gobuster dir -u "$TARGETURL" -w "$SELECTED_WORDLIST"
fi
