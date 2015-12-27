# old school deployment method using DSC!
Import-Module AzureRM
Import-Module Azure
Login-AzureRmAccount
$loc = "West Europe"

# stole below from http://blogs.technet.com/b/heyscriptingguy/archive/2013/06/03/generating-a-new-password-with-windows-powershell.aspx
Function GET-Temppassword() {
    Param( [int]$length=10, [string[]]$sourcedata )
    For ($loop=1; $loop –le $length; $loop++) {
        $TempPassword+=($sourcedata | GET-RANDOM)
    }
    return $TempPassword
}
$ascii=$NULL;For ($a=33;$a –le 126;$a++) {$ascii+=,[char][byte]$a }
$password = GET-Temppassword –length 128 –sourcedata $ascii

# want to get the VS 2015 enterprise image running windows 10
$image = (Get-AzureVMImage | Where-Object Location -CMatch $loc | Where-Object ImageName -like "*VS-2015*ent*W10*")[0].ImageName
$name = "vs15w10azuresdvm01"

# create the VM
$vm = New-AzureVMConfig `
    -Name $name `
    -InstanceSize Small `
    -ImageName $image

# add admin account
$vm = Add-AzureProvisioningConfig `
    -VM $vm `
    -Windows `
    -AdminUsername "admin_account" `
    -Password $password

# add the deployment script as learned from https://azure.microsoft.com/en-us/blog/automating-vm-customization-tasks-using-custom-script-extension/
$vm = Set-AzureVMCustomScriptExtension `
    -VM $vm `
    -FileUri "https://raw.githubusercontent.com/RolfEleveld/Deployment/master/Development_Machine_DSC_Install.ps1", "https://raw.githubusercontent.com/RolfEleveld/Deployment/master/Development_Machine_DSC_Data.ps1" `
    -Run "Development_Machine_DSC_Install.ps1"

# deploy the VM
New-AzureVM `
    -VM $vm `
    -Location $loc `
    -ServiceName $name `
    -DnsSettings $name `
    -WaitForBoot

# VM details
$avm = Get-AzureVM `
    -ServiceName $name `
    -Name $name

# shutting down VM
Stop-AzureVM `
    -ServiceName $name `
    -Name $name

# machine:
$avm

# Password
$password
