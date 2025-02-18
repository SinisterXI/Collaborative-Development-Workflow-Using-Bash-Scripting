# Automated Collaborative Development Workflow

This script automates the process of monitoring files for changes, committing and pushing updates to GitHub, and notifying collaborators via email using the SendGrid API.

## Prerequisites

- Git installed and configured
- SendGrid account and API key
- Configured GitHub repository

## Setup

1. Clone or download this repository.
2. Update the `config.cfg` file with your repository path, the file/directory to monitor, Git remote, branch, and SendGrid credentials.
3. Make the script executable:
   ```bash
   chmod +x monitor_and_push.sh
