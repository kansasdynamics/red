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

### *Nmap Helper*  
Provides simple user prompts to customize nmap commands.

```
sudo chmod +x nmap_helper.sh  
./nmap_helper.sh
```  
*Nmap Sample Output*  

![Nmap Sample Output](https://user-images.githubusercontent.com/89443340/194994657-1ab67344-9f36-4525-81cd-19164f964176.png "Nmap Sample Output")

### *Footprint Report*  
Enumerate a target website to generate a footprint report.

```
sudo chmod +x footprint_report.sh  
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

![Office Password Sample Output](https://user-images.githubusercontent.com/89443340/236116076-9168d1e2-95f4-44af-8b62-6dabbf4082ea.png "Init Project Sample Output")

### *Auto Harvest*  
This script runs theHarvester against many sources automatically for information gathering.

```
sudo chmod +x auto_harvest.sh  
./auto_harvest.sh
``` 

### *gobuster Directories*  
Runs gobuster directory enumeration with additional user-friendly inputs.

```
sudo chmod +x gobuster_directories.sh  
./gobuster_directories.sh 
``` 
*gobuster Directories Sample Output*  

![gobuster Directories Sample Output](https://github.com/kansasdynamics/red/assets/89443340/db7326a7-d7b6-427b-807a-bae5d45d298b.png "gobuster Directories Sample Output")
