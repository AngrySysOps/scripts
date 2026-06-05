#Modification of William Lam script for Windows PowerShell 5.1-friendly code:
#Full code PS7 version: https://williamlam.com/2026/06/vcf-9-1-deploying-vcf-management-services-vcfms-to-non-management-network-during-vcf-upgrade.html

### CONFIGURATION VARIABLES SECTION ###

# 1. Core Core Infrastructure Targets
$SDDCManagerFQDN                 = "sddc-manager.example.com"
$SDDCManagerAdminPassword        = "YourSuperSecureSDDCAdminPassword"
$VCFOperationsFQDN               = "vcf-ops-cluster.example.com"
$VCFOperationsAdminPassword      = "YourSuperSecureVFOpsAdminPassword"

# 2. Target VDS Network Configuration Profile (Dedicated /27 Example Subnet)
$VCFManagementServicesNetworkName    = "DVPG-VCF-Dedicated-Runtime" # Exact Distributed Portgroup Name in vCenter
$VCFManagementServicesNetworkNetmask = "255.255.255.224"            # Subnet mask for /27
$VCFManagementServicesNetworkGateway = "192.168.100.1"             # Subnet Default Gateway

# 3. Consolidated Microservice Hostnames & Dedicated IP Assignments
$VCFManagementServicesRuntimeFQDN   = "vcfms-runtime.example.com"  # IP: 192.168.100.2
$VCFManagementServicesFleetFQDN     = "vcfms-fleet.example.com"    # IP: 192.168.100.15
$VCFManagementServicesInstanceFQDN  = "vcfms-instance.example.com" # IP: 192.168.100.16
$VCFLicenseServerFQDN               = "vcfms-license.example.com"  # IP: 192.168.100.17

# Legacy 9.0 Identity Broker FQDN (Preserved for migration)
$VCFIdentityBrokerFQDN              = "videntity-broker.example.com"

# The mandatory 12-IP Allocation Pool for the internal runtime container worker nodes
$VCFManagementServicesIps = @(
    "192.168.100.3", "192.168.100.4", "192.168.100.5", "192.168.100.6",
    "192.168.100.7", "192.168.100.8", "192.168.100.9", "192.168.100.10",
    "192.168.100.11", "192.168.100.12", "192.168.100.13", "192.168.100.14"
)

# 4. Security Passwords & Sizing Constants
# NOTE: Password must meet strict Linux/K8s complexity guidelines (>15 characters, special characters, numbers)
$VCFManagementServicesPassword       = "VcfmsApplianceComplexPassword123!" 
$VCFManagementServicesSize           = "SMALL"
$VCFManagementServicesInternalClusterCIDR = "172.27.0.0/16"

# 5. Execution Flags
$ValidateOnly       = $true    # Set to $false to perform actual live deployment after successful validation
$OutputJsonPayload  = $false


### DO NOT EDIT BEYOND HERE (WINDOWS POWERSHELL 5.1 COMPATIBLE ENGINE) ###

# Global session interceptors forcing Windows PS 5.1 to ignore self-signed certs and enforce TLS 1.2
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

Function My-Logger {
    param(
        [Parameter(Mandatory=$true)][String]$message,
        [Parameter(Mandatory=$false)][String]$color="green"
    )
    $timeStamp = Get-Date -Format "MM-dd-yyyy_hh:mm:ss"
    Write-Host -NoNewline -ForegroundColor White "[$timestamp]"
    Write-Host -ForegroundColor $color " $message"
}

Function Get-TlsCertificateSha256Fingerprint {
    param(
        [Parameter(Mandatory = $true)][string]$HostName,
        [Parameter(Mandatory = $false)][int]$Port = 443,
        [Parameter(Mandatory = $false)][int]$TimeoutMs = 10000
    )
    $tcpClient = $null
    $sslStream = $null
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $connectTask = $tcpClient.ConnectAsync($HostName, $Port)
        if (-not $connectTask.Wait($TimeoutMs)) { throw "Timed out connecting to ${HostName}:${Port}" }
        $sslStream = New-Object System.Net.Security.SslStream($tcpClient.GetStream(), $false, { param($sender, $certificate, $chain, $sslPolicyErrors) return $true })
        $sslStream.AuthenticateAsClient($HostName)
        if (-not $sslStream.RemoteCertificate) { throw "No remote certificate was presented by ${HostName}:${Port}" }
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($sslStream.RemoteCertificate)
        
        # Backward-compatible .NET SHA256 stream creation for Windows PowerShell 5.1
        $sha256 = [System.Security.Cryptography.SHA256]::Create()
        $hashBytes = $sha256.ComputeHash($cert.RawData)
        $sha256.Dispose()
        return ([BitConverter]::ToString($hashBytes)).Replace('-', ':').ToUpperInvariant()
    }
    finally {
        if ($sslStream) { $sslStream.Dispose() }
        if ($tcpClient) { $tcpClient.Dispose() }
    }
}

# Resolve VCF Operations Thumbprint
$vcf02Sha256 = Get-TlsCertificateSha256Fingerprint -HostName $VCFOperationsFQDN
$payload = @{ "username" = "admin@local"; "password" = $SDDCManagerAdminPassword }
$body = $payload | ConvertTo-Json
$headers = @{ "Content-Type" = "application/json" }

if($ValidateOnly) { My-Logger "### VALIDATION MODE ONLY ###" "cyan" }
My-Logger "Retrieving access token from SDDC Manager ..."
$request = Invoke-WebRequest -Uri "https://${SDDCManagerFQDN}/v1/tokens" -Method POST -Body $body -Headers $headers
if($request.StatusCode -eq 200) { $accesToken = ($request.Content | ConvertFrom-Json).accessToken }
$headers += @{ "Authorization" = "Bearer ${accesToken}" }

# Build Payload using ordered hashtables to protect nested object parsing
$payload = [ordered]@{
    vcfOperationsSpec = [ordered]@{
        "nodes" = @( @{ hostname = $VCFOperationsFQDN; type = "master"; sslThumbprint = $vcf02Sha256 } )
        adminUserPassword = $VCFOperationsAdminPassword
        loadBalancerFqdn = ""
        useExistingDeployment = $true
    }
    vspClusterSpec = [ordered]@{
        platformFqdn = $VCFManagementServicesRuntimeFQDN
        systemUserPassword = $VCFManagementServicesPassword
        ipv4Pool = @{ addresses = $VCFManagementServicesIps }
        size = $VCFManagementServicesSize
        internalClusterCidrIpv4 = $VCFManagementServicesInternalClusterCIDR
        instanceFqdn = $VCFManagementServicesInstanceFQDN
        fleetFqdn = $VCFManagementServicesFleetFQDN
        useExistingDeployment = $false
    }
    vcfManagementComponentsInfrastructureSpec = [ordered]@{
        localRegionNetwork = [ordered]@{
            networkName = $VCFManagementServicesNetworkName
            subnetMask = $VCFManagementServicesNetworkNetmask
            gateway = $VCFManagementServicesNetworkGateway
        }
        xRegionNetwork = [ordered]@{
            networkName = $VCFManagementServicesNetworkName
            subnetMask = $VCFManagementServicesNetworkNetmask
            gateway = $VCFManagementServicesNetworkGateway
        }
    }
    licenseServerSpec = @{hostname = $VCFLicenseServerFQDN}
    vidbSpec = @{hostname = $VCFIdentityBrokerFQDN}
    fleetLcmSpec = @{}
    sddcLcmSpec = @{}
    fleetDepotSpec = @{}
    telemetryAcceptorSpec = @{}
    saltSpec = @{}
    saltRaasSpec = @{}
}

$body = $payload | ConvertTo-Json -Depth 10
if($OutputJsonPayload) { $body }

try {
    My-Logger "Starting VCF Management Services (VCFMS) Deployment Validation ..."
    $request = Invoke-WebRequest -Uri "https://${SDDCManagerFQDN}/v1/vcf-management-components/validations" -Method POST -Body $body -Headers $headers -ErrorAction Stop
    $taskId = ($request.Content | ConvertFrom-Json).id
    if ([string]::IsNullOrWhiteSpace($taskId)) { throw "Validation task id was not returned by the API." }
    My-Logger "Validation task id: ${taskId}"

    $executionPendingStates = @("PENDING", "IN_PROGRESS", "RUNNING", "QUEUED")
    $executionFailureStates = @("FAILED", "ERROR", "CANCELED", "CANCELLED")
    $resultSuccessStates = @("PASSED", "SUCCESS", "SUCCEEDED", "SUCCESSFUL")
    $resultFailureStates = @("FAILED", "ERROR", "CANCELED", "CANCELLED")

    do {
        $request = Invoke-WebRequest -Uri "https://${SDDCManagerFQDN}/v1/vcf-management-components/validations/${taskId}" -Method GET -Headers $headers -ErrorAction Stop
        $task = $request.Content | ConvertFrom-Json
        $executionStatus = [string]$task.executionStatus
        if ([string]::IsNullOrWhiteSpace($executionStatus)) { $executionStatus = [string]$task.status }
        $resultStatus = [string]$task.resultStatus

        if ([string]::IsNullOrWhiteSpace($resultStatus)) {
            My-Logger "Validation task executionStatus: ${executionStatus}" "yellow"
        } else {
            My-Logger "Validation task executionStatus: ${executionStatus}, resultStatus: ${resultStatus}" "yellow"
        }

        if ($executionPendingStates -contains $executionStatus.ToUpperInvariant()) { Start-Sleep -Seconds 10; continue }
        if ($executionFailureStates -contains $executionStatus.ToUpperInvariant()) { throw "Validation task ${taskId} encountered an execution error." }

        if ($executionStatus.ToUpperInvariant() -eq "COMPLETED") {
            if ($resultSuccessStates -contains $resultStatus.ToUpperInvariant()) {
                My-Logger "Validation completed successfully." "green"; break
            }
            if ($resultFailureStates -contains $resultStatus.ToUpperInvariant()) {
                My-Logger "Validation failed with resultStatus ${resultStatus}." "red"
                $allChecks = @($task.validationChecks)
                if ($allChecks.Count -gt 0) {
                    $index = 1
                    foreach ($check in $allChecks) {
                        $description = [string]$check.description
                        $remediation = "No remediation provided"
                        if ($check.errorResponse -and -not [string]::IsNullOrWhiteSpace([string]$check.errorResponse.remediationMessage)) {
                            $remediation = [string]$check.errorResponse.remediationMessage
                        }
                        Write-Host -ForegroundColor Cyan ("`t{0}. {1}" -f $index, $description)
                        Write-Host -ForegroundColor Cyan ("`t`tremediation: {0}" -f $remediation)
                        $index++
                    }
                }
                throw "Validation failed for task ${taskId}. Verify error details above."
            }
        }
    } while ($true)
}
catch {
    My-Logger "Validation request failed: $($_.Exception.Message)" "red"
    if ($_.Exception.Response -and $_.Exception.Response.Content) {
        $errorBody = $_.Exception.Response.Content.ReadAsStringAsync().Result
        if ($errorBody) { Write-Host $errorBody }
    }
    throw
}

# Live Trigger: Fires only if $ValidateOnly is explicitly set to $false
if($ValidateOnly -eq $false) {
    My-Logger "Validation Passed! Kicking off live deployment onto network ${VCFManagementServicesNetworkName} ..."
    Invoke-WebRequest -Uri "https://${SDDCManagerFQDN}/v1/vcf-management-components" -Method POST -Body $body -Headers $headers
}
