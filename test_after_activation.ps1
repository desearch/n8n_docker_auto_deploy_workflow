# Test n8n webhook after workflow activation
# Expected: Succeed with a JSON response containing the greeting

param(
    [string]$Uri = "http://localhost:5678/webhook/test-greeting",
    [string]$Name = "TestUserAfter"
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

# Add a short delay and retry mechanism in case the container/workflow isn't immediately ready
$maxRetries = 5
$retryDelaySeconds = 3
$retryCount = 0

do {
    try {
        $response = Invoke-RestMethod -Uri $Uri -Method POST -Body $body -Headers $headers -ErrorAction Stop
        Write-Host "Success! Received:"
        Write-Host ($response | ConvertTo-Json -Depth 5)

        # Basic validation: Check if the response contains a 'message' field
        if ($response -ne $null -and $response.PSObject.Properties['message']) {
            Write-Host "Response contains expected 'message' field. Test Passed."
            exit 0 # Exit successfully
        } else {
            Write-Host "Response received, but it doesn't contain the expected 'message' field."
            exit 1 # Exit with error code
        }

    } catch {
        # Try to get HTTP status info if it's a WebException
        if ($_.Exception -is [System.Net.WebException] -and $_.Exception.Response -ne $null) {
            $statusCode = $_.Exception.Response.StatusCode.value__
            $statusDescription = $_.Exception.Response.StatusDescription
            Write-Host "Received Error: Status Code $statusCode ($statusDescription)"
            
            # Try to get response body for more details
            try {
                $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                $reader.BaseStream.Position = 0
                $reader.DiscardBufferedData()
                $responseBody = $reader.ReadToEnd()
                Write-Host "Response body: $responseBody"
            } catch {
                Write-Host "Could not read response body"
            }
            
            $retryCount++
            if ($retryCount -lt $maxRetries) {
                Write-Host "Retrying in $retryDelaySeconds seconds... ($retryCount/$maxRetries)"
                Start-Sleep -Seconds $retryDelaySeconds
            } else {
                Write-Host "Max retries reached. Test Failed."
                exit 1 # Exit with error code after max retries
            }
        } else {
            # Handle other types of errors during retry loop
            Write-Host "An unexpected non-HTTP error occurred during retry attempt:"
            Write-Host $_.Exception.Message
            $retryCount++
            if ($retryCount -lt $maxRetries) {
                Write-Host "Retrying in $retryDelaySeconds seconds... ($retryCount/$maxRetries)"
                Start-Sleep -Seconds $retryDelaySeconds
            } else {
                Write-Host "Max retries reached after non-HTTP errors. Test Failed."
                exit 1 # Exit with error code after max retries
            }
        }
    }
} while ($retryCount -lt $maxRetries) 