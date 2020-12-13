$exportPath = C:\temp\MSOL-MultiTenantUserReport.csv
$credential = Get-Credential
connect-msolservice -Credential $credential
$clients = Get-MsolPartnerContract -All

foreach ($client in $clients) { 

    Get-MsolUser -All -TenantId $client.TenantId | 
    Select-Object @{N = 'Tenant Name'; E = { (Get-MsolDomain -TenantId $client.TenantId | Where-Object { $_.IsInitial -eq "True" } | Select-Object -ExpandProperty Name) } },
    DisplayName,
    @{N = 'Username'; E = { ($_.UserPrincipalName) } },
    @{N = 'MFA Status'; E = { ($_.StrongAuthenticationRequirements.State) } },
    @{N = 'Default MFA Method'; E = { (Get-MsolUser -UserPrincipalName $_.UserPrincipalName -TenantId $client.TenantId | Select-Object -ExpandProperty StrongAuthenticationMetWhere-Object | Where-Object { $_.IsDefault }).MethodType } },
    UserType,
    @{N = 'Sign In Blocked'; E = { ($_.BlockCredential) } },
    IsLicensed,
    @{N = 'Licenses'; E = { (Get-MsolUser -UserPrincipalName $_.UserPrincipalName -TenantId $client.TenantId | Select-Object -ExpandProperty Licenses | Select-Object AccountSkuId | ForEach-Object { $_.AccountSkuId } ) } },
    StrongPasswordRequired,
    LastPasswordChangeTimestamp,
    PasswordNeverExpires,
    WhenCreated,
    @{N = 'User Roles'; E = { (Get-MsolUserRole -UserPrincipalName $_.UserPrincipalName -TenantId $client.TenantId | Select-Object -ExpandProperty Name) } } | Export-CSV $exportPath -Append -NoTypeInformation

}


