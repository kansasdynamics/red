import os
import subprocess
import sys
from datetime import datetime

def list_nmap_scripts():
    # The directory where NSE scripts are typically located
    script_directory = "/usr/share/nmap/scripts/"
    
    # Check if the directory exists
    if not os.path.exists(script_directory):
        print(f"Nmap scripts directory not found: {script_directory}")
        return []
    
    # List all scripts in the directory and sort them alphabetically
    scripts = sorted([f for f in os.listdir(script_directory) if f.endswith('.nse')])
    
    # Display scripts to the user
    print("\nAvailable Nmap Scripts (Alphabetized):")
    for i, script in enumerate(scripts, 1):
        print(f"{i}. {script}")
    
    return scripts

def run_nmap_scan(targets, scan_type, custom_options, output_file):
    # Construct the full Nmap command
    nmap_command = f"nmap {custom_options} {targets} -oN {output_file}"
    
    # Print the command to the terminal with an extra line break
    print(f"\nRunning the following Nmap command:\n")
    print(nmap_command)
    print("\n")  # Add an extra carriage return for clarity
    
    # Log the command at the top of the output file
    with open(output_file, "w") as log_file:
        log_file.write(f"# Nmap command run:\n# {nmap_command}\n\n")
    
    # Execute the Nmap command
    subprocess.run(nmap_command, shell=True)
    print(f"\nScan complete. Results saved to {os.path.abspath(output_file)}")

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

    # Prompt for additional Nmap options based on scan type
    custom_options = ""
    if scan_type == "ping":
        exclude_hosts = input("Enter any hosts to exclude from the scan (comma-separated), or leave blank: ")
        if exclude_hosts:
            custom_options += f"--exclude {exclude_hosts} "
    elif scan_type == "syn":
        port_range = input("Enter the port range to scan (e.g., 1-65535), or leave blank for default: ")
        timing = input("Enter the timing template (T0 to T5), or leave blank for default: ")
        if port_range:
            custom_options += f"-p {port_range} "
        if timing:
            custom_options += f"-{timing} "
    elif scan_type == "version":
        include_os = input("Include OS detection? (yes/no): ").lower()
        if include_os == "yes":
            custom_options += "-O "
    elif scan_type == "script":
        available_scripts = list_nmap_scripts()
        if available_scripts:
            script_choices = input("Enter the numbers of the scripts to run (comma-separated), or leave blank for default: ")
            if script_choices:
                # Strip spaces and process script choices
                script_choices = script_choices.replace(" ", "")
                selected_scripts = [available_scripts[int(choice) - 1] for choice in script_choices.split(",") if choice.isdigit() and 0 < int(choice) <= len(available_scripts)]
                custom_options += f"--script {','.join(selected_scripts)} "
    elif scan_type == "os":
        include_version = input("Include service version detection? (yes/no): ").lower()
        if include_version == "yes":
            custom_options += "-sV "

    # Ensure the basic scan type option is included
    if scan_type == "ping":
        custom_options += "-sn "
    elif scan_type == "syn":
        custom_options += "-sS "
    elif scan_type == "version":
        custom_options += "-sV "
    elif scan_type == "script":
        custom_options += "-sC "
    elif scan_type == "os":
        custom_options += "-O "

    return targets, scan_type, custom_options

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
    
    targets, scan_type, custom_options = get_user_input()

    # Generate dynamic output filename
    output_file = generate_output_filename(scan_type, targets)

    # Run the selected Nmap scan
    run_nmap_scan(targets, scan_type, custom_options, output_file)

if __name__ == "__main__":
    main()
