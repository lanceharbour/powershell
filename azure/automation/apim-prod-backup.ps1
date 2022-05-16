<#
    .DESCRIPTION
        Runbook to backup APIM to blob storage

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

    .PARAMETER BackupFilePrefix
        Specifies the backup blob file prefix. The suffix will be automatically generated based on the date in the format
        yyyyMMddHHmm followed by the .bak file extension. Default value apim-.

    .PARAMETER RetentionDays
        Specifies the number of days how long backups are kept in blob storage. The default value is 30 days as the backups
        expire after that. Script will remove all older files from container, thus a dedicated container should be used
        for this script.

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
    [string]$BlobContainerName,
    [parameter(Mandatory=$false)]
    [string]$BackupFilePrefix = "apim-",
    [parameter(Mandatory=$false)]
	[Int32]$RetentionDays = 30
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

function backupAPIM([string]$apimResourceGroupName, [string]$apimInstanceName, $storageContext, [string]$blobContainerName, [string]$backupPrefix) {
	$backupBlobName = $backupPrefix + (Get-Date).ToString("yyyyMMddHHmm") + ".bak"
	Write-Output "Starting APIM backup to blob '$blobContainerName/$backupBlobName'" -Verbose
	Backup-AzApiManagement -Name $apimInstanceName -ResourceGroupName $apimResourceGroupName -StorageContext $storageContext `
                       -TargetContainerName $blobContainerName `
                       -TargetBlobName $backupBlobName
}

function removeOldBackups([int]$retentionDays, [string]$blobContainerName, $storageContext) {
	Write-Output "Removing backups older than '$retentionDays' days from container: '$blobContainerName'"
	$isOldDate = [DateTime]::UtcNow.AddDays(-$retentionDays)
	$blobs = Get-AzStorageBlob -Container $blobContainerName -Context $storageContext
	foreach ($blob in ($blobs | Where-Object { $_.LastModified.UtcDateTime -lt $isOldDate -and $_.BlobType -eq "BlockBlob" })) {
		Write-Output ("Removing blob: " + $blob.Name) -Verbose
		Remove-AzStorageBlob -Blob $blob.Name -Container $blobContainerName -Context $storageContext
	}
}

#Turn off autosaving Azure credentials in this powershell session
Disable-AzContextAutosave -Scope Process | Out-Null

#Starting backup
Write-Output "Starting APIM backup" -Verbose
Write-Output "Establishing storage context" -Verbose
#Create storage context
$StorageContext = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey

login

backupAPIM `
    -apimResourceGroupName $ApimResourceGroupName `
    -apimInstanceName $ApimInstanceName `
    -storageContext $StorageContext `
    -blobContainerName $BlobContainerName `
    -backupPrefix $BackupFilePrefix

removeOldBackups `
    -retentionDays $RetentionDays `
    -storageContext $StorageContext `
    -blobContainerName $BlobContainerName

Write-Output "APIM backup script finished" -Verbose