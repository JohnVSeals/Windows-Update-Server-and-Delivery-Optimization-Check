# List of Windows Update and Delivery Optimization endpoints
$endpoints = @(
    # Windows update servers
    "windowsupdate.microsoft.com",
    "update.microsoft.com",
    "download.windowsupdate.com",
    "download.microsoft.com",
    # Delivery Optimization Servers
    "do.dsp.mp.microsoft.com",
    "delivery.mp.microsoft.com"
)

# Function to test connection to an endpoint
Function Test-Endpoint {
    param (
        [string]$Endpoint
    )

    try {
        # Resolve the DNS name to get a list of IP addresses
        $ip4Addresses = Resolve-DnsName -Name $Endpoint -ErrorAction SilentlyContinue | Where-Object { $_.QueryType -eq "A" } | Select-Object -ExpandProperty IPAddress -ErrorAction SilentlyContinue
        $ip6Addresses = Resolve-DnsName -Name $Endpoint -ErrorAction SilentlyContinue | Where-Object { $_.QueryType -eq "AAAA" } | Select-Object -ExpandProperty IPAddress -ErrorAction SilentlyContinue

        if ($ip4Addresses) {
            # Test connection to each IPv4 address
            foreach ($ip in $ip4Addresses) {
                $result = Test-NetConnection -ComputerName $ip -Port 443 -InformationLevel Detailed
                if ($result.TcpTestSucceeded) {
                    Write-Host "Connection to $Endpoint ($ip) succeeded" -ForegroundColor Green
                } else {
                    Write-Host "Connection to $Endpoint ($ip) failed" -ForegroundColor Red
                }
            }
        } else {
            Write-Host "No IPv4 addresses found for $Endpoint" -ForegroundColor Yellow
        }

        if ($ip6Addresses) {
            # Test connection to each IPv6 address
            foreach ($ip in $ip6Addresses) {
                $result = Test-NetConnection -ComputerName $ip -Port 443 -InformationLevel Detailed
                if ($result.TcpTestSucceeded) {
                    Write-Host "Connection to $Endpoint ($ip) succeeded" -ForegroundColor Green
                } else {
                    Write-Host "Connection to $Endpoint ($ip) failed" -ForegroundColor Red
                }
            }
        } else {
            Write-Host "No IPv6 addresses found for $Endpoint" -ForegroundColor Yellow
        }

    } catch {
        Write-Host "Error testing $Endpoint : $_" -ForegroundColor Red
    }
}

# Test each endpoint in a loop
for ($i = 0; $i -lt $endpoints.Count; $i++) {
    $endpoint = $endpoints[$i]
    Write-Host "Testing connection to $endpoint..."
    Test-Endpoint -Endpoint $endpoint
}
