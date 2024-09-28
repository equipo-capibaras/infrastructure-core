# Core Infrastructure
This repository serves as a centralized collection of Terraform configurations for core infrastructure components used within our platform.

## Contents
- **Load Balancer:** Terraform code for provisioning and configuring the load balancer to distribute incoming traffic.
- **API Gateway:** Configurations for setting up and managing the API gateway to handle API requests and responses.
- **GitHub Integration:** Terraform scripts to establish integration with GitHub for automated workflows and deployments.
- **Artifact Registry:** Code to create and manage artifact registries for storing container images and build artifacts.
- **Monitoring:** Terraform definitions for implementing monitoring solutions to track infrastructure health and performance.

## Important Notes
- **Environment Variables:** Sensitive information, such as API keys or credentials, should be stored as environment variables and referenced within the Terraform configurations.
- **State Management:** Terraform state is managed remotely in a designated GCP bucket for better collaboration and consistency.
- **Testing:** Thoroughly test any changes to configurations in a development environment before applying them to production.

## Configuration variables
The following variables are required to be configured:

- `gcp_project_id`: The ID of the Google Cloud Platform project where resources will be provisioned.
- `github_org_id`: The ID of the GitHub organization used for integration and automation.
- `domain`: The domain name associated with the deployed services or applications.
