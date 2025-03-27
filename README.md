# hyperv_iis_ansible
Building IIS in Hyper-V with Ansible extras

# Instructions
Grab the 2025 ISO
Mount it
Make a new directory

Copy the contents of the ISO + unattend.xml to that new directory
Create a new iso

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
Create an unattend.xml with a user/pass for autologin
powershell script to automate
1. Create an internal network in Hyper-V
2. Create VMSs in Hyper-V
2. Mount ISO to VMs
3. Set ISO to boot
4. User prompt to proceed with rest of the setups
    **Might require a revisit... this is still slow/manual**

# In Progress

**Generic**
1. Ensure Ansible User is created and in Adninistrators Group
2. Enable WinRm
3. Enable SSH
4. WinGet Goodies, dotnet, notepad, windirstat, etc
5. ...

**Ansible**
1. Connect to VMs via BASIC
2. Install IIS
3. Setup a site
4. ...