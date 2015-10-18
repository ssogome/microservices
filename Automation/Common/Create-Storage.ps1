﻿<#
.Synopsis 
    This PowerShell script provisions a Storage Account
.Description 
    This PowerShell script provisions  Storage Account
.Notes 
    File Name  : Create-Storage.ps1
    Author     : Ron Bokleman, Bob Familiar
    Requires   : PowerShell V4 or above, PowerShell / ISE Elevated

    Please do not forget to ensure you have the proper local PowerShell Execution Policy set:

        Example:  Set-ExecutionPolicy Unrestricted 

    NEED HELP?

    Get-Help .\Create-Storage.ps1 [Null], [-Full], [-Detailed], [-Examples]

.Link   
    https://microservices.codeplex.com/

.Parameter Subscription
    Example:  mysubscription
.Parameter StorageAccountName
    Example:  mystorage
.Parameter StorageResourceGroup
    Example:  storage_rg
.Parameter AzureLocation
    Example:  East US
.Example
    .\Create-Storage.ps1 -Subscription mysubscription -StorageAccountName mystorage -AzureLocation East US
.Inputs
    The [Subscription] parameter is the name of the Azure subscription.
    The [StorageAccountName] parameter is the name of the Storage Account
    The [AzureLocation] parameter is the name of the Azure Region/Location: East US, Central US, West US.
.Outputs
    Console
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True, Position=0, HelpMessage="The storage account name.")]
    [string]$Subscription,
    [Parameter(Mandatory=$True, Position=1, HelpMessage="The storage account name.")]
    [string]$StorageAccountName,
    [Parameter(Mandatory=$True, Position=2, HelpMessage="The storage resource group.")]
    [string]$StorageResourceGroup,
    [Parameter(Mandatory=$True, Position=3, HelpMessage="The name of the Azure Region/Location: East US, Central US, West US.")]
    [string]$AzureLocation
)

#######################################################################################
# F U N C T I O N S
#######################################################################################

Function Select-Subscription()
{
    Param([String] $Subscription)

    Try
    {
        Select-AzureSubscription -SubscriptionName $Subscription -ErrorAction Stop

        # List Subscription details if successfully connected.
        Get-AzureSubscription -Current -ErrorAction Stop

        Write-Verbose -Message "Currently selected Azure subscription is: $Subscription."
    }
    Catch
    {
        Write-Verbose -Message $Error[0].Exception.Message
        Write-Verbose -Message "Exiting due to exception: Subscription Not Selected."
    }
}

##########################################################################################
# M A I N
##########################################################################################

$Error.Clear()

# Mark the start time.
$StartTime = Get-Date

# Select Subscription
Select-Subscription $Subscription

Import-module "C:\Program Files (x86)\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure"

if (Test-AzureName -Storage -Name $StorageAccountName) 
{
    "Storage account name '$StorageAccountName' is already taken, try another one"
} 
else 
{
    $Result = New-AzureStorageAccount -StorageAccountName $StorageAccountName -ResourceGroupName $StorageResourceGroup -Type Standard_GRS -Location $AzureLocation
    If ($Result.OperationStatus -eq "Succeeded") {
        $Result | Out-String
        "Created new Storage Account '$StorageAccountName', in '$Location'"
        Set-AzureSubscription –SubscriptionName $Subscription -CurrentStorageAccount $StorageAccountName 
    } else {
        "Failed to create new Storage Account '$StorageAccountName'"
    }
}

# Mark the finish time.
$FinishTime = Get-Date

#Console output
$TotalTime = ($FinishTime - $StartTime).TotalSeconds
Write-Verbose -Message "Elapse Time (Seconds): $TotalTime"