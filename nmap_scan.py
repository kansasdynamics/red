import os
import subprocess
import sys
from datetime import datetime

def run_nmap_scan(targets, scan_type, output_file):
    # Define Nmap command based on the scan type
    if scan_type == "ping_sweep":
        nmap_command = f"nmap -sn {targets} -oN {output_file}"
    elif scan_type == "syn_scan":
        nmap_command = f"nmap -sS {targets} -oN {output_file}"
    elif scan_type == "version_detection":
        nmap_command = f"nmap -sV {targets} -oN {output_file}"
    elif scan_type == "script_scan":
        nmap_command = f"nmap -sC {targets} -oN {output_file}"
    elif scan_type == "os_detection":
        nmap_command = f"nmap -O {targets} -oN {output_file}"
    else:
        raise ValueError("Invalid scan type selected.")

    # Execute the Nmap command
    print(f"Running {scan_type} on {targets}...")
    subprocess.run(nmap_command, shell=True)
    print(f"Scan complete. Results saved to {os.path.abspath(output_file)}")

def get_user_input():
    # Prompt for IP address/range or file with targets
    targets = input("Enter the IP address, range, or the path to a file with targets: ")

    # If the input is a file, read the contents
    if os.path.isfile(targets):
        with open(targets, 'r') as file:
            targets = file.read().strip().replace('\n', ' ')

    # Prompt for scan type
    print("\nSelect the type of scan to perform:")
    print("1. Ping Sweep")
    print("2. SYN Scan")
    print("3. Version Detection")
    print("4. Script Scan")
    print("5. OS Detection")
    scan_choice = input("Enter the number corresponding to the scan type: ")

    scan_types = {
        "1": "ping_sweep",
        "2": "syn_scan",
        "3": "version_detection",
        "4": "script_scan",
        "5": "os_detection"
    }

    scan_type = scan_types.get(scan_choice)

    if not scan_type:
        print("Invalid choice! Please run the script again and select a valid scan type.")
        exit(1)

    # Prompt for output file name
    output_file = input("Enter the output file name (leave blank for default): ")

    if not output_file:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        output_file = f"nmap_scan_{timestamp}.txt"

    return targets, scan_type, output_file

def check_sudo():
    if os.geteuid() != 0:
        print("This script requires sudo privileges. Re-running with sudo...")
        # Re-run the script with sudo
        args = ['sudo', 'python3'] + sys.argv
        os.execvp('sudo', args)

def main():
    check_sudo()
    print("Welcome to the Automated Nmap Scan Script")
    print("----------------------------------------")
    
    targets, scan_type, output_file = get_user_input()

    # Run the selected Nmap scan
    run_nmap_scan(targets, scan_type, output_file)

if __name__ == "__main__":
    main()
