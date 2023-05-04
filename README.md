# Red Team Scripts
The scripts in this repository are primarily for penetration testing and malware proofs of concept. 

### *Init Project*  
Create a directory structure for a forensics project and run initial Nmap and Gobuster scans on the target.

```
sudo chmod +x init_project.sh  
./init_project.sh
```  
*Init Project Sample Output*  

![Init Project Sample Output](https://user-images.githubusercontent.com/89443340/194686187-f68290f4-57fa-4a9f-8dda-67f1edd3ee20.png "Init Project Sample Output")

### *Nmap Prompts*  
Create a directory structure for a forensics project and run initial Nmap and Gobuster scans on the target based on input from prompts.

```
sudo chmod +x nmap.sh  
./nmap_prompts.sh
```  
*Nmap Sample Output*  

![Nmap Sample Output](https://user-images.githubusercontent.com/89443340/194994657-1ab67344-9f36-4525-81cd-19164f964176.png "Nmap Sample Output")

### *Footprint Report*  
Enumerate a target website to generate a footprint report.

```
sudo chmod +x footprint.sh  
./footprint_report.sh
``` 

### *Flood C:*  
Floods the C:\ drive on a Windows computer with randomly generated files dispersed in random directories until there is no more available space.

```
.\flood_c.ps1
``` 

### *Office Password*  
Runs the office2john.py script against password protected Microsoft Office documents to attempt to crack the hash and reveal the password.

```
sudo chmod +x office_password.sh  
./office_password.sh
``` 
*Office Password Sample Output*  

![Office Password Sample Output](https://user-images.githubusercontent.com/89443340/194686187-f68290f4-57fa-4a9f-8dda-67f1edd3ee20.png "Init Project Sample Output")
