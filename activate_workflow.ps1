# Import and activate n8n workflow
$workflowJson = Get-Content -Raw -Path "workflows/greeting_workflow.json" | ConvertFrom-Json
$workflowJson.PSObject.Properties.Remove('id')
$workflowJsonString = $workflowJson | ConvertTo-Json -Depth 10

if (-not $env:N8N_API_KEY) {
    Write-Host "Error: N8N_API_KEY environment variable not set"
    exit 1
}

$headers = @{
    "X-N8N-API-KEY" = $env:N8N_API_KEY
    "Content-Type" = "application/json"
}

Write-Host "Waiting for n8n to start..."
Start-Sleep -Seconds 15

Write-Host "Importing workflow..."
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5678/api/v1/workflows" -Method Post -Headers $headers -Body $workflowJsonString
    $workflowId = $response.id
    Write-Host "Workflow imported with ID: $workflowId"

    Write-Host "Activating workflow..."
    $activateResponse = Invoke-RestMethod -Uri "http://localhost:5678/api/v1/workflows/$workflowId/activate" -Method Post -Headers $headers
    Write-Host "Workflow activated successfully!"
    exit 0
} catch {
    Write-Host "Error occurred:"
    Write-Host $_.Exception.Message
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd()
        Write-Host $responseBody
    }
    exit 1
} 