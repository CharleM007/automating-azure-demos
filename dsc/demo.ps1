
.  ../login.ps1

# Needs to run on Windows box
# Unless on a Linux box with DSC for Linux installed

$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

$resourceGroup = "ms-workshop-default"
$location = "West Europe"

$vmName = 'demovm01'
$storageAccountName = 'rsworkshopdemosadsc'

# Publish the configuration script to user storage
Publish-AzureRmVMDscConfiguration -Verbose -Force `
    -ConfigurationPath .\DemoServer.ps1 `
    -ResourceGroupName $resourceGroup `
    -StorageAccountName $storageAccountName

# Set the VM to run the DSC configuration
Set-AzureRmVMDscExtension -Verbose `
    -Version '2.76' `
    -ResourceGroupName $resourceGroup `
    -VMName $vmName `
    -ArchiveStorageAccountName $storageAccountName `
    -ArchiveBlobName 'DemoServer.ps1.zip' `
    -AutoUpdate `
    -ConfigurationName 'DemoServer'

# This will take ages
