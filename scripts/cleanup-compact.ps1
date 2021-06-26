#Powershell version of install cleanup_compact 

# get the windows kernel version
$KERNELVERSION = [Environment]::OSVersion.Version

choco install sdelete -force

# Stops the windows update service.  
Stop-Service -Name wuauserv -Force -EA 0 
Get-Service -Name wuauserv

# Delete the contents of windows software distribution.
write-output "Delete the contents of windows software distribution" 
Get-ChildItem "C:\Windows\SoftwareDistribution\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | remove-item -force -recurse -ErrorAction SilentlyContinue 

# Delete the contents of localuser apps.
write-output "Delete the contents of localuser apps" 
Get-ChildItem "C:\users\localuser\AppData\Local\Packages\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | remove-item -force -recurse -ErrorAction SilentlyContinue 

# Delete the contents of user template desktop.
write-output "Delete the contents of user template desktop"
Get-ChildItem "C:\Users\Public\Desktop\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | remove-item -force -recurse -ErrorAction SilentlyContinue 
 
# Starts the Windows Update Service 
Start-Service -Name wuauserv -EA 0

# use dism to cleanup windows sxs. This only works on 2012r2 and 8.1 and above. 
# bumped up to windows 10 only as was failing on 2012r2
if ([Environment]::OSVersion.Version -ge [Version]"10.0") {
  write-output "Cleaning up winSXS with dism"
  dism /online /cleanup-image /startcomponentcleanup /resetbase /quiet
}

# Zero dirty blocks
write-output "Starting to Zero blocks"
#New-Item -Path "HKCU:\Software\Sysinternals\SDelete" -force -ErrorAction SilentlyContinue
#Set-ItemProperty -Path "HKCU:\Software\Sysinternals\SDelete" -Name EulaAccepted -Value "1" -Type DWORD -force
start-process -FilePath 'C:\ProgramData\chocolatey\bin\sdelete.exe' -ArgumentList '-q -z C:' -wait -EA 0
choco uninstall sdelete -force

exit 0



