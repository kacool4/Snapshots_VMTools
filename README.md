# Snapshot operations, VMware Tools installations and Virtual Machine information gathering report

## Scope:
Script that creates, delete and views snapshots from all Virtual Machines that are included in Servers.txt file. Check and set VMware Tools to install after next powercycle. General information for the Virtual Machines included in the ```servers.txt```.
 

## Requirements:
* Windows Server 2012 and above or Windows 10
* Powershell 5.1 and above
* PowerCLI either standalone or import the module in Powershell (Preferred)
* A text file "servers.txt" in order to specify vms

## Configuration

Specify the location of the servers.txt or leave it as default (It will search for the file in the same folder as the script is stored)
```powershell
$vmList = Get-Content servers.txt
```
Write the vms in the servers.txt as a list and not as a single line seperated by comma.
```
Valid list of vms 
VM1
VM2
VM3
VM4

Not Valid
VM1,VM2,VM3,VM4
```

## Example

  ![Alt text](/screenshot/mainmenu.jpg?raw=true "Main Menu")

### Virtual Machine Information Report
It will create an CSV file with details on all the Virtual Machines you specify in the ```servers.txt``` file.

### VMware Tools Status
You can check the status and version of VMware Tools by selecting the number 2. To upgrade or install the VMware Tools press the number 3 and the script will enable the option to upgrade the VMware Tools on next power cycle. 

### Snapshots
 When you choose to create a snapshot the script will ask for a Title and a description in order to put it in the details
 You can either perform all snapshots at the same time (choice 7) or one by one (choice 5)
 
 You can also check if there are currently any snapshots by using menu no 4.
 
 In case you want to delete snapshots choose menu 9 and the script will ask you for the title and it will delete only the snapshots that have this title.If you want to delete ALL snapshots in the vCenter just press enter and the script will remove all snapshots in general regardless the title.
