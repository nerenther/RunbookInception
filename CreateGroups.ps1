Param (  
    [Parameter(Mandatory = $True)][string]$Tenantname,
    [Parameter(Mandatory = $True)][string]$ApplicationID,
    [Parameter(Mandatory = $True)][string]$ApplicationSecret
)  
 
Write-Verbose "Runbook started"
#region Part 1

#########################################################################################
#
#       Part 1 - Getting data and token
#
#########################################################################################

#Getting token from Graph
Write-Verbose "Composing body for token request"
try {
    $ReqTokenBody = @{
        Grant_Type    = "client_credentials"
        Scope         = "https://graph.microsoft.com/.default"
        client_Id     = $ApplicationID
        Client_Secret = $ApplicationSecret
    }
    Write-Verbose "Body composed"
}

catch {
    Write-Verbose "Failed to compose body"
    Write-Output $Error[0]
    throw "Failed to compose body"
}

Write-Verbose "Invoking rest method to get token from graph"
try {
    $TokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$($Tenantname)/oauth2/v2.0/token" -Method POST -Body $ReqTokenBody
    Write-Verbose "Got token"
}

catch {
    Write-Verbose "Failed to get token"
    Write-Output $Error[0]
    throw "Failed to get token"
}

Write-Verbose "Setting headerParams"
$headerParams = @{
    'Authorization' = "Bearer $($TokenResponse.access_token)"
    'Content-Type' = "application/json"
}

Write-Verbose "Finished with part 1"
#endregion

#region Part 2
#########################################################################################
#
#       Part 2 - Creating groups
#
#########################################################################################

#Creating dynamic group for Intune users
Write-Verbose "Composing body for intuneEnabledUsers"
$dynamicGroupProperties = @{
    "description" = "All users with active Intune license";
    "displayName" = "IntuneEnabledUsers";
    "groupTypes" = @("DynamicMembership");
    "mailEnabled" = $False;
    "mailNickname" = "IntuneEnabledUsers";
    "membershipRule" = "user.assignedPlans -any (assignedPlan.service -eq `"SCO`" -and assignedPlan.capabilityStatus -eq `"Enabled`")";
    "membershipRuleProcessingState" = "On";
    "securityEnabled" = $True
}
Write-Verbose "Body composed"

try {
    Write-Verbose "Creating Dynamic group"
    $IntuneGroup = Invoke-WebRequest -Headers $headerParams -uri "https://graph.microsoft.com/v1.0/groups" -Body (ConvertTo-Json $dynamicGroupProperties) -method POST -UseBasicParsing
    Write-Verbose "Group created"
    #Write-Output "Created dynamic Intune users group"
}

catch {
    Write-Verbose "Failed to create group"
    Write-Output $Error[0]
    throw "Failed to create group"
}

#Creating security group for Profile1
Write-Verbose "Composing body for profile1"
$profile1GroupProperties = @{
    "description" = "Users that should use Profile1";
    "displayName" = "Profile1";
    "groupTypes" = @();
    "mailEnabled" = $False;
    "mailNickname" = "Profile1";
    "securityEnabled" = $True
}
Write-Verbose "Body composed"

try {
    Write-Verbose "Creating security group"
    $Profile1Group = Invoke-WebRequest -Headers $headerParams -uri "https://graph.microsoft.com/v1.0/groups" -Body (ConvertTo-Json $profile1GroupProperties) -method POST -UseBasicParsing
    Write-Verbose "Group created"
    #Write-Output "Created Profile1 security group"
}

catch {
    Write-Verbose "Failed to create group"
    Write-Output $Error[0]
    throw "Failed to create group"
}

#Creating security group for ConditionalAccess
Write-Verbose "Composing body for ConditionalAccess"
$ConditionalAccessGroupProperties = @{
    "description" = "Users that should use ConditionalAccess";
    "displayName" = "ConditionalAccess";
    "groupTypes" = @();
    "mailEnabled" = $False;
    "mailNickname" = "ConditionalAccess";
    "securityEnabled" = $True;
    "members@odata.bind" = @("https://graph.microsoft.com/v1.0/groups/$(($Profile1Group | ConvertFrom-Json).id)")
}
Write-Verbose "Body composed"

try {
    Write-Verbose "Creating security group"
    $ConditionalAccessGroup = Invoke-WebRequest -Headers $headerParams -uri "https://graph.microsoft.com/v1.0/groups" -Body (ConvertTo-Json $ConditionalAccessGroupProperties) -method POST -UseBasicParsing
    Write-Verbose "Group created"
    #Write-Output "Created ConditionalAccess security group"
}

catch {
    Write-Verbose "Failed to create group"
    Write-Output $Error[0]
    throw "Failed to create group"
}

#Creating security group for ConfigurationPolicies
Write-Verbose "Composing body for ConfigurationPolicies"
$ConfigurationPoliciesGroupProperties = @{
    "description" = "Users that should use ConfigurationPolicies";
    "displayName" = "ConfigurationPolicies";
    "groupTypes" = @();
    "mailEnabled" = $False;
    "mailNickname" = "ConfigurationPolicies";
    "securityEnabled" = $True;
    "members@odata.bind" = @("https://graph.microsoft.com/v1.0/groups/$(($Profile1Group | ConvertFrom-Json).id)")
}
Write-Verbose "Body composed"

try {
    Write-Verbose "Creating security group"
    $ConfigurationPoliciesGroup = Invoke-WebRequest -Headers $headerParams -uri "https://graph.microsoft.com/v1.0/groups" -Body (ConvertTo-Json $ConfigurationPoliciesGroupProperties) -method POST -UseBasicParsing
    Write-Verbose "Group created"
    #Write-Output "Created ConfigurationPolicies security group"
}

catch {
    Write-Verbose "Failed to create group"
    Write-Output $Error[0]
    throw "Failed to create group"
}

#Creating security group for IdentityProtection
Write-Verbose "Composing body for IdentityProtection"
$IdentityProtectionGroupProperties = @{
    "description" = "Users that should use IdentityProtection";
    "displayName" = "IdentityProtection";
    "groupTypes" = @();
    "mailEnabled" = $False;
    "mailNickname" = "IdentityProtection";
    "securityEnabled" = $True;
    "members@odata.bind" = @("https://graph.microsoft.com/v1.0/groups/$(($Profile1Group | ConvertFrom-Json).id)")
}
Write-Verbose "Body composed"

try {
    Write-Verbose "Creating security group"
    $IdentityProtectionGroup = Invoke-WebRequest -Headers $headerParams -uri "https://graph.microsoft.com/v1.0/groups" -Body (ConvertTo-Json $IdentityProtectionGroupProperties) -method POST -UseBasicParsing
    Write-Verbose "Group created"
    #Write-Output "Created IdentityProtection security group"
}

catch {
    Write-Verbose "Failed to create group"
    Write-Output $Error[0]
    throw "Failed to create group"
}

#Creating security group for MCAS
Write-Verbose "Composing body for MCAS"
$MCASGroupProperties = @{
    "description" = "Users that should use MCAS";
    "displayName" = "MCAS";
    "groupTypes" = @();
    "mailEnabled" = $False;
    "mailNickname" = "MCAS";
    "securityEnabled" = $True;
    "members@odata.bind" = @("https://graph.microsoft.com/v1.0/groups/$(($Profile1Group | ConvertFrom-Json).id)")
}
Write-Verbose "Body composed"

try {
    Write-Verbose "Creating security group"
    $MCASGroup = Invoke-WebRequest -Headers $headerParams -uri "https://graph.microsoft.com/v1.0/groups" -Body (ConvertTo-Json $MCASGroupProperties) -method POST -UseBasicParsing
    Write-Verbose "Group created"
    #Write-Output "Created MCAS security group"
}

catch {
    Write-Verbose "Failed to create group"
    Write-Output $Error[0]
    throw "Failed to create group"
}

#endregion