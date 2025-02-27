function Invoke-CIPPStandardDisableAdditionalStorageProviders {
    <#
    .FUNCTIONALITY
    Internal
    #>
    param($Tenant, $Settings)

    $AdditionalStorageProvidersState = New-ExoRequest -tenantid $Tenant -cmdlet 'Get-OwaMailboxPolicy' -cmdParams @{Identity = 'OwaMailboxPolicy-Default' }

    if ($Settings.remediate) {

        try {
            if ($AdditionalStorageProvidersState.AdditionalStorageProvidersAvailable) {
                New-ExoRequest -tenantid $Tenant -cmdlet 'Set-OwaMailboxPolicy' -cmdParams @{ Identity = $AdditionalStorageProvidersState.Identity; AdditionalStorageProvidersAvailable = $false } -useSystemMailbox $true
                Write-LogMessage -API 'Standards' -tenant $tenant -message 'OWA additional storage providers have been disabled.' -sev Info
                $AdditionalStorageProvidersState.AdditionalStorageProvidersAvailable = $false
            } else {
                Write-LogMessage -API 'Standards' -tenant $tenant -message 'OWA additional storage providers are already disabled.' -sev Info
            }
        } catch {
            Write-LogMessage -API 'Standards' -tenant $tenant -message "Failed to disable OWA additional storage providers. Error: $($_.Exception.Message)" -sev Error
        }

    }

    if ($Settings.alert) {
            
        if ($AdditionalStorageProvidersState.AdditionalStorageProvidersAvailable) {
            Write-LogMessage -API 'Standards' -tenant $tenant -message 'OWA additional storage providers are enabled' -sev Alert
        } else {
            Write-LogMessage -API 'Standards' -tenant $tenant -message 'OWA additional storage providers are disabled' -sev Info
        }
    }

    if ($Settings.report) {
        
        Add-CIPPBPAField -FieldName 'AdditionalStorageProvidersEnabled' -FieldValue [bool]$AdditionalStorageProvidersState.AdditionalStorageProvidersEnabled -StoreAs bool -Tenant $tenant
    }
}