# hyperv_iis_ansible
Building IIS in Hyper-V with Ansible extras

# Instructions
1. Grab the 2025 ISO
2. Mount it
3. Make a new directory
4. Copy the contents of the ISO + unattend.xml to that new directory
5. Create a new iso  

**Note: UEFI (Gen2 VMs in Hyper-V) + efisys_noprompt.bin skips the “Press any key to boot from CD/DVD...” promp +-udfver102**

# Tools
Hyper-V  
Powershell 7  
Windows2025 ISO  
Microsoft ADK (to create iso)  
WSL  
Python  
PyWinrm  
Ansible  

# Completed
- Create an unattend.xml  
- Create VMS in Hyper-V  
- Mount ISO to VMs  
- Set ISO to boot  
- Enable WinRM and SSH  


# In Progress

**Generic** // **Ansible**
- Ensure Ansible User is created and in Adninistrators Group
- Hostnames  
- Set IPs to static
- Connect to VMs via WinRM and/or SSH 
- Use Winget to install apps
    - Powershell 7  
    - dotnet 8/9  
    - 7-Zip  
    - Notepad ++  
    - Git  
    - Sysinternal 
- Install IIS  
- Setup IIS  
- Setup a site  
- Deploy some code  


- ...  