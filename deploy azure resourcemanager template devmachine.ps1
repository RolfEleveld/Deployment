# using https://azure.microsoft.com/en-us/documentation/articles/resource-group-template-deploy/
# in case needed to convert for Mac: https://azure.microsoft.com/en-us/documentation/articles/resource-group-template-deploy/
# credentials
$sub = "Visual Studio Enterprise with MSDN"
$name = "win10clouddev"
$resourcegroup = "Win10CloudDev"
$templatePath = "https://raw.githubusercontent.com/RolfEleveld/Deployment/master/devmachine.azuredeploy.json"
#make sure you have created the module with Publish-AzureVMDscConfiguration -ConfigurationPath .\Development_Machine_DSC_Data.ps1  -ConfigurationArchivePath .\Development_Machine_DSC_Data.ps1.zip
$dscPath = "https://raw.githubusercontent.com/RolfEleveld/Deployment/master/Development_Machine_DSC_Data.ps1.zip"
$dscConfig = "Development_Machine_DSC_Data.ps1\DevelopmentMachineConfiguration"
$loc = "West Europe"


#make sure we have the Azure Powershell components
#(new-object Net.WebClient).DownloadString("http://psget.net/GetPsGet.ps1") | iex
#(new-object Net.WebClient).DownloadString("https://raw.githubusercontent.com/Azure/azure-powershell/fab05c12ba4baae218c7aab251b3b435ea961956/setup-powershellget/Setup/ShortcutStartup.ps1") | iex
## above does same as below
##$tempfilename = "$env:temp\TEMP-$(Get-Date -format 'yyyy-MM-dd hh-mm-ss').ps1"
##(new-object net.webclient).DownloadFile('https://raw.githubusercontent.com/Azure/azure-powershell/fab05c12ba4baae218c7aab251b3b435ea961956/setup-powershellget/Setup/ShortcutStartup.ps1',$tempfilename)
##& $tempfilename

# stole below from http://blogs.technet.com/b/heyscriptingguy/archive/2013/06/03/generating-a-new-password-with-windows-powershell.aspx
Function GET-Temppassword() {
    Param( [int]$length=10, [string[]]$sourcedata )
    For ($loop=1; $loop –le $length; $loop++) {
        $TempPassword+=($sourcedata | GET-RANDOM)
    }
    return $TempPassword
}
$ascii=$NULL;For ($a=33;$a –le 126;$a++) {$ascii+=,[char][byte]$a }
$password = GET-Temppassword –length 122 –sourcedata $ascii #max 123 characters

# answers JSON object
$ans = @{
    vmAdminUserName="AdminWin10CloudDev"
    vmAdminPassword=$password
    deployLocation=$loc
    storageName="win10clouddevstorage"
    vmName=$name
#    vmSize="Standard_DS2"
#    storageType="Premium_LRS"
#    vmVisualStudioVersion="VS-2015-Pro-VSU1-AzureSDK-2.8-W10T-N-x64"
    vmIPPublicDnsName=$name
    modulesUrl=$dscPath
    configurationFunction=$dscConfig
}

# set up resource manager account
Import-Module AzureRM
Login-AzureRmAccount
Get-AzureRmSubscription –SubscriptionName $sub | Select-AzureRmSubscription

# get the Resource group
$rgroup = $null
$rgroup = Get-AzureRmResourceGroup -Name $resourcegroup -ErrorAction SilentlyContinue
if ($rgroup -eq $null){ # resource group not found
    $rgroup = New-AzureRmResourceGroup -Name $resourcegroup -Location $loc
}

# using JSON to delpoy
Test-AzureRmResourceGroupDeployment -ResourceGroupName $resourcegroup `
    -TemplateFile $templatePath `
    -TemplateParameterObject $ans

# actually deploying
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourcegroup `
    -Name $name `
    -TemplateFile $templatePath `
    -TemplateParameterObject $ans

# see deployment errors or results.
Get-AzureRmResourceGroupDeployment -ResourceGroupName $resourcegroup -Name $name

# cleanup the entire resourcegroup!
#Remove-AzureRmResourceGroup -Name $resourcegroup -ErrorAction SilentlyContinue -Force