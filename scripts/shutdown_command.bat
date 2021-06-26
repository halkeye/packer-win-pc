:: rmdir /q /s c:\windows\temp
netsh advfirewall firewall set rule name="WinRM-HTTP" new action=block
C:/windows/system32/sysprep/sysprep.exe /generalize /oobe /quiet /shutdown "/unattend:C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\Unattend.xml"
