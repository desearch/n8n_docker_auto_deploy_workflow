# Test complete workflow with environment variables
# Read API key from .env file
$envContent = Get-Content .env
$env:N8N_API_KEY = ($envContent | Where-Object { $_ -match '^N8N_API_KEY=' }) -replace '^N8N_API_KEY=', ''

if (-not $env:N8N_API_KEY) {
    Write-Host "Error: N8N_API_KEY not found in .env file"
    exit 1
}

# Stop any existing containers
Write-Host "Stopping any existing containers..."
docker-compose down

# Start n8n
Write-Host "Starting n8n..."
docker-compose up -d

# Wait for n8n to start
Write-Host "Waiting for n8n to start..."
Start-Sleep -Seconds 15

# Import and activate workflow
Write-Host "Importing and activating workflow..."
.\activate_workflow.ps1

# Test before activation (should fail)
Write-Host "Testing before activation (should fail)..."
.\test_before_activation.ps1

# Test after activation (should succeed)
Write-Host "Testing after activation (should succeed)..."
.\test_after_activation.ps1

# Clean up
Write-Host "Cleaning up..."
docker-compose down 