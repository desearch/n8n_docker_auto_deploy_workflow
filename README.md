# n8n Docker Automatic Workflow Deployment

This project demonstrates how to set up and automate n8n workflow deployment using Docker Compose. It includes scripts for importing, activating, and testing workflows automatically.

## Prerequisites

- Docker
- Docker Compose
- PowerShell (for running the scripts)

## Project Structure

```
.
├── .env                    # Environment variables (not tracked in git)
├── .gitignore             # Git ignore rules
├── activate_workflow.ps1   # Script to import and activate workflow
├── docker-compose.yml      # Docker Compose configuration
├── test_after_activation.ps1  # Test script for active workflow
├── test_before_activation.ps1 # Test script for inactive workflow
├── test_workflow_with_env.ps1 # Complete test script
├── workflows/              # Directory containing workflow definitions
└── n8n-data/              # n8n data directory (not tracked in git)
```

## Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/desearch/n8n_docker_auto_deploy_workflow.git
   cd n8n_docker_auto_deploy_workflow
   ```

2. Create a `.env` file with your n8n API key:
   ```
   N8N_API_KEY=your_api_key_here
   ```

## Configuration

### Docker Compose

The `docker-compose.yml` file configures n8n with:
- Port 5678 exposed
- Environment variables loaded from `.env`
- Persistent volumes for n8n data and workflows
- API key authentication

### Workflow

The example workflow (`workflows/greeting_workflow.json`) is a simple webhook that:
- Accepts POST requests with a `name` parameter
- Returns a greeting message with the current timestamp

## Usage

### Manual Testing

1. Start n8n:
   ```powershell
   docker-compose up -d
   ```

2. Import and activate workflow:
   ```powershell
   .\activate_workflow.ps1
   ```

3. Test the workflow:
   ```powershell
   .\test_after_activation.ps1
   ```

### Automated Testing

Run the complete test suite:
```powershell
.\test_workflow_with_env.ps1
```

This script will:
1. Stop any existing containers
2. Start n8n
3. Import and activate the workflow
4. Run both test scripts
5. Clean up by stopping containers

## Scripts

### activate_workflow.ps1
- Imports the workflow from JSON file
- Activates the workflow
- Uses environment variables for API key

### test_before_activation.ps1
- Tests the webhook before activation
- Expects a 404 error
- Uses environment variables for API key

### test_after_activation.ps1
- Tests the webhook after activation
- Expects a successful response
- Includes retry mechanism
- Uses environment variables for API key

### test_workflow_with_env.ps1
- Complete test suite
- Handles environment variables
- Manages container lifecycle
- Runs all tests in sequence

## Security

- API keys are stored in `.env` file (not tracked in git)
- n8n data directory is excluded from version control
- Basic authentication is disabled in favor of API key authentication

## Troubleshooting

1. If tests fail, check:
   - n8n container is running
   - API key is correct
   - Workflow is properly imported
   - Webhook URL is correct

2. Common issues:
   - Container startup time: Scripts include delays for container initialization
   - API key authentication: Ensure API key is properly set in `.env`
   - Network issues: Check if port 5678 is available

## License

[Your License Here]

## Contributing

[Your Contribution Guidelines Here] 