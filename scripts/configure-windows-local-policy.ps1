# start logging
start-transcript -path c:\windows\temp\configure-windows-local-policy.log -append

$ProgressPreference="SilentlyContinue"

# install PolicyFileEditor
Install-Module -Name PolicyFileEditor -Confirm:$false

# disable windows defender
Set-PolicyFileEntry -Path $env:systemroot\system32\GroupPolicy\Machine\registry.pol -Key "Software\Policies\Microsoft\Windows Defender" -ValueName DisableAntiSpyware -Data 1 -Type DWord

# reg unload
Set-PolicyFileEntry -Path $env:systemroot\system32\GroupPolicy\Machine\registry.pol -Key "Software\Policies\Microsoft\Windows\System" -ValueName DisableForceUnload -Data 1 -Type DWord

# ProcessCreationIncludeCmdLine_Enabled
Set-PolicyFileEntry -Path $env:systemroot\system32\GroupPolicy\Machine\registry.pol -Key "Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit" -ValueName ProcessCreationIncludeCmdLine_Enabled -Data 1 -Type DWord

# set RDP Min encryption level
Set-PolicyFileEntry -Path $env:systemroot\system32\GroupPolicy\Machine\registry.pol -Key "Software\Policies\Microsoft\Windows NT\Terminal Services" -ValueName MinEncryptionLevel -Data 3 -Type DWord

# set RPC encryption 
Set-PolicyFileEntry -Path $env:systemroot\system32\GroupPolicy\Machine\registry.pol -Key "Software\Policies\Microsoft\Windows NT\Terminal Services" -ValueName fEncryptRPCTraffic -Data 1 -Type DWord

Set-PolicyFileEntry -Path $env:systemroot\system32\GroupPolicy\Machine\registry.pol -Key "Software\Policies\Microsoft\Windows NT\Terminal Services" -ValueName fPromptForPassword -Data 1 -Type DWord

# limit log size
limit-eventlog -logname Security -MaximumSize 1048576kb

# show results
write-output "Listing configured local windows policies"
Get-PolicyFileEntry -Path $env:systemroot\system32\GroupPolicy\Machine\registry.pol -All

write-output  "Configure local security policy"
secedit /export /cfg c:\windows\temp\secpol.cfg
(get-content c:\windows\temp\secpol.cfg).replace('PasswordComplexity = 0', 'PasswordComplexity = 1') | Out-File c:\windows\temp\secpol.cfg
(get-content c:\windows\temp\secpol.cfg).replace('MaximumPasswordAge = 42', 'MaximumPasswordAge = 90') | Out-File c:\windows\temp\secpol.cfg
(get-content c:\windows\temp\secpol.cfg).replace('MaximumPasswordAge = 0', 'MaximumPasswordAge = 90') | Out-File c:\windows\temp\secpol.cfg
(get-content c:\windows\temp\secpol.cfg).replace('PasswordHistorySize = 0', 'PasswordHistorySize = 10') | Out-File c:\windows\temp\secpol.cfg
(get-content c:\windows\temp\secpol.cfg).replace('DontDisplayLastUserName=4,0', 'DontDisplayLastUserName=4,1') | Out-File c:\windows\temp\secpol.cfg
(get-content c:\windows\temp\secpol.cfg).replace('CachedLogonsCount=1,"10"', 'CachedLogonsCount=1,"4"') | Out-File c:\windows\temp\secpol.cfg
(get-content c:\windows\temp\secpol.cfg).replace('RestrictAnonymous=4,0', 'RestrictAnonymous=4,1') | Out-File c:\windows\temp\secpol.cfg
(get-content c:\windows\temp\secpol.cfg).replace('FilterAdministratorToken=4,0', 'FilterAdministratorToken=4,1') | Out-File c:\windows\temp\secpol.cfg
(get-content c:\windows\temp\secpol.cfg).replace('LockoutBadCount = 0', "LockoutBadCount = 5`nResetLockoutCount = 15`nLockoutDuration = 15`n") | Out-File c:\windows\temp\secpol.cfg
(get-content c:\windows\temp\secpol.cfg).replace('MinimumPasswordLength = 8', 'MinimumPasswordLength = 12') | Out-File c:\windows\temp\secpol.cfg
(get-content c:\windows\temp\secpol.cfg).replace('MinimumPasswordLength = 0', 'MinimumPasswordLength = 12') | Out-File c:\windows\temp\secpol.cfg
(get-content c:\windows\temp\secpol.cfg).replace('FilterAdministratorToken=4,0', 'FilterAdministratorToken=4,1') | Out-File c:\windows\temp\secpol.cfg
get-content c:\windows\temp\secpol.cfg
secedit /configure /db c:\windows\security\local.sdb /cfg c:\windows\temp\secpol.cfg /areas SECURITYPOLICY

#audit policy
write-output  "Configure local audit policy"
auditpol /set /subcategory:"Credential Validation" /failure:enable /success:enable
auditpol /set /subcategory:"Application Group Management" /failure:enable /success:enable
auditpol /set /subcategory:"Computer Account Management" /failure:enable /success:enable
auditpol /set /subcategory:"Distribution Group Management" /failure:enable /success:enable
auditpol /set /subcategory:"Other Account Management Events" /failure:enable /success:enable
auditpol /set /subcategory:"Security Group Management" /failure:enable /success:enable
auditpol /set /subcategory:"User Account Management" /failure:enable /success:enable
auditpol /set /subcategory:"Process Creation" /success:enable
auditpol /set /subcategory:"Account Lockout" /failure:enable /success:enable
auditpol /set /subcategory:"File Share" /failure:enable
auditpol /set /subcategory:"Registry" /failure:enable
auditpol /set /subcategory:"Removable Storage" /failure:enable /success:enable
auditpol /set /subcategory:"SAM" /failure:enable /success:enable
auditpol /set /subcategory:"Audit Policy Change" /failure:enable /success:enable
auditpol /set /subcategory:"Authentication Policy Change" /failure:enable /success:enable
auditpol /set /subcategory:"Sensitive Privilege Use" /success:enable
auditpol /set /subcategory:"Security State Change" /failure:enable /success:enable
auditpol /set /subcategory:"Security System Extension" /failure:enable /success:enable
auditpol /set /subcategory:"Process Termination" /failure:enable /success:enable

# report audit policy
auditpol.exe /get /category:*

stop-transcript
exit 0
