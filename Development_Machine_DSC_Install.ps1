# set up package providers
Get-PackageProvider -Name NuGet -ForceBootstrap
Start-DscConfiguration -Path .\Development_Machine_DSC_Data -Wait -Verbose

# add Choclatey
# command line: @powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Expression ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
Invoke-Expression ((New-Object Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
# deploy Chocolatey packages:
choco install notepad2
choco install git
choco install fiddler4
choco install 7zip
choco install paint.net
choco install linqpad4
choco install foxitreader
choco install irfanview
choco install irfanviewplugins
choco install handbrake

# force enable remote desktop access
Start-DscConfiguration -ComputerName 'localhost' -wait -force 

# add me as an admin may need to be substituted by MicrosoftAccount\mail@live.com
net user /add "rolf@bajomero.com" 
net localgroup Administrators /add "rolf@bajomero.com"

#https://raw.githubusercontent.com/RolfEleveld/Deployment/master/Development_Machine_DSC_Data.ps1
