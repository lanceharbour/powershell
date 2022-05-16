<#
    .DESCRIPTION
        Runbook to restore APIM from blob storage

    .NOTES
        AUTHOR: Lance Harbour
        LASTEDIT: Dec 20, 2021

    .PARAMETER ApimResourceGroupName
	Specifies the name of the resource group where the Azure Api Management instance is located.

    .PARAMETER ApimInstanceName
        Specifies the name of the Azure Api Management which script will backup.

    .PARAMETER StorageAccountName
        Specifies the name of the storage account where backup file will be uploaded.

    .PARAMETER StorageAccountKey
        Specifies the key of the storage account where backup file will be uploaded.

    .PARAMETER BlobContainerName
        Specifies the container name of the storage account where backup file will be uploaded.

    .PARAMETER BackupBlobName
        Specifies the backup blob to restore from.

    .INPUTS
        None.

    .OUTPUTS
        Human-readable informational and error messages produced during the job. Not intended to be consumed by another runbook.
#>

param(
    [parameter(Mandatory=$true)]
    [String] $ApimResourceGroupName,
    [parameter(Mandatory=$true)]
    [String] $ApimInstanceName,
    [parameter(Mandatory=$true)]
    [String]$StorageAccountName,
    [parameter(Mandatory=$true)]
    [String]$StorageAccountKey,
    [parameter(Mandatory=$true)]
    [String]$BlobContainerName,
    [parameter(Mandatory=$true)]
    [String]$BackupBlobName
)

function login() {
    Write-Output "Logging in to Azure..."
    try {
        $AzureContext = (Connect-AzAccount -Identity).context
        }
    catch{
            Write-Output "There is no system-assigned user identity. Aborting."
            exit
        }
    $AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext
}

function restoreAPIM([string]$apimResourceGroupName, [string]$apimInstanceName, $storageContext, [string]$blobContainerName, [string]$backupBlobName) {
    Write-Output "Restoring backup '$backupBlobName' to '$apimInstanceName' instance." -Verbose
    Restore-AzApiManagement -ResourceGroupName $apimResourceGroupName -Name $apimInstanceName -StorageContext $storageContext -SourceContainerName $blobContainerName -SourceBlobName $backupBlobName
}

#Turn off autosaving Azure credentials in this powershell session
Disable-AzContextAutosave -Scope Process | Out-Null

#Starting restore from blog
Write-Output "Starting APIM restore" -Verbose
Write-Output "Establishing storage context" -Verbose

#Create storage context
$StorageContext = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey

login

restoreAPIM `
    -apimResourceGroupName $ApimResourceGroupName `
    -apimInstanceName $ApimInstanceName `
    -storageContext $StorageContext `
    -blobContainerName $BlobContainerName `
    -backupBlobName $BackupBlobName

Write-Output "APIM restore script finished" -Verbose