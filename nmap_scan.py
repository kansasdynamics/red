import os
import subprocess
import sys
from datetime import datetime

def run_nmap_scan(targets, scan_type, output_file):
    # Define Nmap command based on the scan type
    if scan_type == "ping":
        nmap_command = f"nmap -sn {targets} -oN {output_file}"
    elif scan_type == "syn":
        nmap_command = f"nmap -sS {targets} -oN {output_file}"
    elif scan_type == "version":
        nmap_command = f"nmap -sV {targets} -oN {output_file}"
    elif scan_type == "script":
        nmap_command = f"nmap -sC {targets} -oN {output_file}"
    elif scan_type == "os":
        nmap_command = f"nmap -O {targets} -oN {output_file}"
    else:
        raise ValueError("Invalid scan type selected.")

    # Execute the Nmap command
    print(f"Running {scan_type} scan on {targets}...")
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
        "1": "ping",
        "2": "syn",
        "3": "version",
        "4": "script",
        "5": "os"
    }

    scan_type = scan_types.get(scan_choice)

    if not scan_type:
        print("Invalid choice! Please run the script again and select a valid scan type.")
        exit(1)

    return targets, scan_type

def generate_output_filename(scan_type, targets):
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    sanitized_targets = targets.replace("/", "_").replace(" ", "_")
    output_file = f"nmap_scan_{scan_type}_{sanitized_targets}_{timestamp}.log"
    return output_file

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
    
    targets, scan_type = get_user_input()

    # Generate dynamic output filename
    output_file = generate_output_filename(scan_type, targets)

    # Run the selected Nmap scan
    run_nmap_scan(targets, scan_type, output_file)

if __name__ == "__main__":
    main()
