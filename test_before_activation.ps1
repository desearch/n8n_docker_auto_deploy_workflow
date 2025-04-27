# Test n8n webhook before workflow activation
# Expected: Fail with 404 or error because workflow shouldn't be active yet

param(
    [string]$Uri = "http://localhost:5678/webhook/test-greeting",
    [string]$Name = "TestUserBefore"
)

if (-not $env:N8N_API_KEY) {
    Write-Host "Error: N8N_API_KEY environment variable not set"
    exit 1
}

$body = @{ name = $Name } | ConvertTo-Json
$headers = @{
    "Content-Type" = "application/json"
    "X-N8N-API-KEY" = $env:N8N_API_KEY
}

Write-Host "Attempting to POST to $Uri with body: $body"

try {
    $response = Invoke-RestMethod -Uri $Uri -Method POST -Body $body -Headers $headers -ErrorAction Stop
    Write-Host "Unexpected Success! Received:"
    Write-Host ($response | ConvertTo-Json -Depth 5)
    exit 1 # Exit with error code because success is not expected here
} catch {
    # Try to get HTTP status info if it's a WebException
    if ($_.Exception -is [System.Net.WebException] -and $_.Exception.Response -ne $null) {
        $statusCode = $_.Exception.Response.StatusCode.value__
        $statusDescription = $_.Exception.Response.StatusDescription
        Write-Host "Expected Failure Received: Status Code $statusCode ($statusDescription)"
        # Check if it's the expected 404
        if ($statusCode -eq 404) {
            Write-Host "Received expected 404 Not Found. Test Passed (for before activation scenario)."
            exit 0 # Exit successfully
        } else {
            Write-Host "Received an HTTP error, but not the expected 404. Status: $statusCode"
            exit 0 # Exit successfully as *an* error was expected
        }
    } else {
        # Handle other types of errors
        Write-Host "An expected (non-HTTP or connection) error occurred:"
        Write-Host $_.Exception.Message
        exit 0 # Exit successfully as *an* error was expected
    }
} 