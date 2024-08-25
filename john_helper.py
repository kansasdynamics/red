import subprocess
import os
import sys
import shutil
import time

def install_john():
    print("Installing John the Ripper...")
    try:
        subprocess.run(['sudo', 'apt-get', 'install', '-y', 'john'], check=True)
        print("John the Ripper installed successfully.")
    except subprocess.CalledProcessError as e:
        print(f"Failed to install John the Ripper: {e}")
        sys.exit(1)

def check_and_install_john():
    if not shutil.which('john'):
        install_john()

def generate_hash_file(target_file):
    hash_file = os.path.splitext(target_file)[0] + "_hash.txt"
    try:
        print(f"Generating hash file: {hash_file}")
        with open(hash_file, 'w') as f:
            subprocess.run(['python3', 'office2john.py', target_file], stdout=f, check=True)
        print(f"Hash file generated: {hash_file}")
    except subprocess.CalledProcessError as e:
        print(f"Failed to generate hash file: {e}")
        sys.exit(1)
    return hash_file

def list_wordlists():
    wordlist_dir = '/usr/share/wordlists'
    wordlists = [f for f in os.listdir(wordlist_dir) if os.path.isfile(os.path.join(wordlist_dir, f))]
    return wordlists

def handle_rockyou():
    rockyou_gz = '/usr/share/wordlists/rockyou.txt.gz'
    rockyou_txt = '/usr/share/wordlists/rockyou.txt'

    if os.path.exists(rockyou_gz) and not os.path.exists(rockyou_txt):
        print("Unzipping rockyou.txt.gz...")
        try:
            subprocess.run(['sudo', 'gzip', '-d', rockyou_gz], check=True)
            print("rockyou.txt has been unzipped.")
        except subprocess.CalledProcessError as e:
            print(f"Failed to unzip rockyou.txt.gz: {e}")
            sys.exit(1)
    return rockyou_txt

def prompt_for_wordlist():
    wordlists = list_wordlists()
    print("Available wordlists:")
    for i, wordlist in enumerate(wordlists, 1):
        print(f"{i}. {wordlist}")

    choice = input("Select a wordlist by number: ").strip()
    try:
        choice_index = int(choice) - 1
        selected_wordlist = wordlists[choice_index]
        if selected_wordlist == 'rockyou.txt.gz':
            return handle_rockyou()
        return os.path.join('/usr/share/wordlists', selected_wordlist)
    except (ValueError, IndexError):
        print("Invalid choice, please try again.")
        return prompt_for_wordlist()

def prompt_for_parameters():
    target_file = input("Enter the path to the target file (e.g., test.xlsx): ").strip()
    wordlist = prompt_for_wordlist()

    output_password_file = os.path.splitext(target_file)[0] + "_password.txt"

    rules = input("Enter any rules for John (or press Enter to skip): ").strip()
    return target_file, wordlist, output_password_file, rules

def generate_timestamped_output_file():
    timestamp = time.strftime("%Y%m%d_%H%M%S")
    output_file = os.path.join(os.getcwd(), f"cracked_passwords_{timestamp}.txt")
    return output_file

def crack_password_john(hash_file, wordlist, output_password_file, rules=None):
    command = ['sudo', 'john', f'--wordlist={wordlist}', hash_file]
    if rules:
        command.extend(['--rules=' + rules])

    print("Executing: " + " ".join(command))
    try:
        result = subprocess.run(command, capture_output=True, text=True)
        output = result.stdout.strip()

        if "No password hashes left to crack" in output:
            new_output_file = generate_timestamped_output_file()
            with open(new_output_file, 'w') as f:
                f.write(output)
            print(f"Password already cracked in a previous session. The details are saved to {new_output_file}")
        elif any(keyword in output for keyword in ["password", "cracked", "Loaded"]):
            with open(output_password_file, 'w') as f:
                f.write(output)
            print(f"Cracking complete. Results saved to {output_password_file}")
        else:
            print("No password found.")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    # Step 1: Check and install John the Ripper if necessary (silent if already installed)
    check_and_install_john()

    # Step 2: Prompt for parameters
    target_file, wordlist, output_password_file, rules = prompt_for_parameters()

    # Step 3: Generate the hash file
    hash_file = generate_hash_file(target_file)

    # Step 4: Run the password cracking process with John the Ripper
    crack_password_john(hash_file, wordlist, output_password_file, rules)
