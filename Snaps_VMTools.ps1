## Connect to vCenter and Load all vm names to variable $VirtualMachines
cls
$vCenter = Read-Host -Prompt "Please type the vCenter IP or FQDN :"
Connect-VIServer -Server $vCenter
$vmList = Get-Content servers.txt

##  Create menu  ######
function menu {
 cls
   Write-Host "================================================" 
   Write-Host "  Welcome to vCenter multiChoice menu."
   Write-Host "================================================
    Please provide number for required action 
   -------------------------------------------
     1. Virtual Machine Information Report
     2. VMware Tools Status
     3. VMware Tools Installation
     4. Check for Snapshop
     5. Create Snapshot (One by one)
     6. Create Snapshot with Quiesce(One by one)
     7. Create Multiple Snapshot
     8. Create Multiple Snapshot with Quiesce
     9. Delete snapshots 
    10.Exit 
   ------------"
 }

 ####################################################################

##  Virtual Machine Information Report "1"  ######
function vm_info {
   ## get the list of VM names from a text file
   get-vm $vmList | Select Name,@{N="OS Version";E={$_.Guest.OSFullName}},@{N="IP Address";E={$_.Guest.IPAddress[0]}},NumCpu,MemoryMB,@{n="Provisionedspace(GB)"; E={[math]::round($_.ProvisionedSpaceGB)}},Version,@{N="Tools Status";E={$_.ExtensionData.Guest.ToolsStatus}}| Export-Csv vm_info.csv
   Write-Host "VM info file is stored in vm_info.csv"
   Write-Host "Please use Excel in order to view the file correctly"
   Start-Sleep -s 3
   Invoke-Item vm_info.csv
   
## Go back to main menu
 back_menu 
 }

####################################################################

##  VMware Tools Status Menu "2"  ######
function vm_tools_info {
   get-vm $vmList | %{get-view $_.id} | Format-Table -AutoSize Name,@{N="Tools version";E={if($_.Guest.ToolsVersion -ne ""){$_.Guest.ToolsVersion}}},@{Name="ToolsStatus";Expression={$_.Guest.ToolsStatus}}| out-file vmtools_info.txt
   Write-Host "VMTools file is stored in vmtools_info.txt"
   Start-Sleep -s 3
   Invoke-Item vmtools_info.txt
   
## Go back to main menu
 back_menu 
 }

####################################################################

##  VMware Tools update after reboot Menu "3"  ######
function vm_tools_update {
    foreach ($vm in (Get-VM -Name $vmList)){
    if($vm.config.Tools.ToolsUpgradePolicy -ne "UpgradeAtPowerCycle") {
        $config = New-Object VMware.Vim.VirtualMachineConfigSpec
        $config.ChangeVersion = $vm.ExtensionData.Config.ChangeVersion
        $config.Tools = New-Object VMware.Vim.ToolsConfigInfo
        $config.Tools.ToolsUpgradePolicy = "UpgradeAtPowerCycle"
        $vm.ExtensionData.ReconfigVM($config)
        Write-Host "Update Tools Policy on $vm completed"
      }
    }
    Write-Host "Policy was set to update vmtools after reboot"

## Go back to main menu
 back_menu 
 }

####################################################################

##  Check for Snapshots Menu "4"  ######
function check_snap {
   Get-VM | Sort Name | Get-Snapshot | Where { $_.Name.Length -gt 0 } | Select VM,Name,Description,@{N="SizeGB";E={[math]::Round(($_.SizeMB/1024),2)}}| Format-Table | out-file snaps_file.txt
   Write-Host "Snapshot file is stored in snaps_file.txt"
   Start-Sleep -s 3
   Invoke-Item snaps_file.txt

## Go back to main menu
 back_menu 
 }

####################################################################

##  Create one-by-one snapshots Menu "5"  ######

function create_one {
## Ask for a change number to put and description
   Write-Host "Snapshot "
   $subject = Read-Host -Prompt "Please enter change number "
   $desc = Read-Host -Prompt "Please enter description "

## Start the snapshots
  foreach ($vmName in $vmList) {
    New-Snapshot -VM $vmName -Name $subject -Description $desc -Memory
 }
## Go back to main menu
 back_menu 
}

####################################################################

##  Create one-by-one snapshots with Quiesce Menu "6"  ######

function create_one_qu {

## Ask for a change number to put and description
   Write-Host "Snapshot "
   $subject = Read-Host -Prompt "Please enter change number "
   $desc = Read-Host -Prompt "Please enter description "

## Start the snapshots with Quiesce
  foreach ($vmName in $vmList) {
    New-Snapshot -VM $vmName -Name $subject -Description $desc -Quiesce -Memory
 }
 
## Go back to main menu
 back_menu  
}


####################################################################

##  Create multiple snapshots Menu "7"  ######

function create_multi {
## Ask for a change number to put and description
   Write-Host "Snapshot "
   $subject = Read-Host -Prompt "Please enter change number "
   $desc = Read-Host -Prompt "Please enter description "

## Create multiple snapshots at once 
 New-Snapshot -VM $vmList -Name $subject -Description $desc -Memory
 
## Go back to main menu
 back_menu 
}

####################################################################

##  Create multiple snapshots with Quiesce Menu "8"  ######

function create_multi_qu {
## Ask for a change number to put and description
   Write-Host "Snapshot "
   $subject = Read-Host -Prompt "Please enter change number "
   $desc = Read-Host -Prompt "Please enter description "

## Create multiple snapshots at once with Quiesce
  New-Snapshot -VM $vmList -Name $subject -Description $desc  -Quiesce -Memory
  
## Go back to main menu
 back_menu 
}

####################################################################

##  Delete snapshots Menu "9"  ######
#### It will delete only snapshots from the server list with the specific change number. If it is wrong or missed typed it will not remove anything

function delete_snaps {
## Ask for a change number to put and description
   Write-Host "Removing Snapshot "
   $subject = Read-Host -Prompt "Please enter change number "
 
## Remove multiple snapshots at once
 get-vm $vmList | get-snapshot  | where {$_.Name -match $subject}| Format-Table -Property VM,Name,Created,Description, @{N="SizeGB";E={[math]::Round(($_.SizeMB/1024),2)}} |out-file remove_snaps.txt 
 get-vm $vmList | get-snapshot  | where {$_.Name -match $subject}| Remove-Snapshot -Confirm:$false
 Invoke-Item remove_snaps.txt
 
## Go back to main menu
 back_menu 
}


####################################################################
##  Back to main menu  ######

function back_menu {
  Start-Sleep -s 3
  mainmenu
}

####################################################################

##  Invalid menu option  ######

function error {
  Write-Host " Invalid menu option. Please try again"
  Start-Sleep -s 2
  mainmenu
}

#################################################################### 

##  Main menu  ######
function mainmenu{
menu 
$Choice = Read-Host -Prompt "Choice" 
  If ($Choice -eq "1") {
       vm_info
       menu
 }
 ElseIf ($Choice -eq "2") {
       vm_tools_info
       menu
 }
 ElseIf ($Choice -eq "3") {
       vm_tools_update
       menu
 }
 ElseIf ($Choice -eq "4") {
       check_snap
       menu
 }
 ElseIf ($Choice -eq "4") {
       check_snap
       menu
 }
 ElseIf ($Choice -eq "5") {
       create_one
 }
 ElseIf ($Choice -eq "6") {
       create_one_qu
 }
 ElseIf ($Choice -eq "7") {
        create_multi
 } 
 ElseIf ($Choice -eq "8") {
       create_one_qu
 }
 ElseIf ($Choice -eq "9") {
       delete_snaps
 }
 ElseIf ($Choice -eq "10"){
      cls
      Write-Host "Existing script."
      Disconnect-VIServer -Server * -Force -Confirm:$false 
 }
 Else {
    error
 }
}

####################################################################

#####Start of Script ############
mainmenu

##################################
