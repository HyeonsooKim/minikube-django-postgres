# Gemini Project Overview

This document provides a comprehensive overview of the Kubernetes-based project, designed for easy onboarding and efficient development.

## Project Description

This project is a single-cluster Kubernetes setup running on Minikube. It consists of a Django application, a PostgreSQL database, and an Nginx server acting as a reverse proxy and serving static files. All Kubernetes resources are managed by Terraform.

## Core Technologies

- **Infrastructure as Code:** Terraform
- **Orchestration:** Kubernetes (Minikube)
- **Backend:** Django
- **Database:** PostgreSQL
- **Web Server/Proxy:** Nginx
- **Containerization:** Docker

## Project Structure

```
/
├── terraform/               # Terraform configuration files
│   ├── main.tf
│   ├── postgres.tf
│   ├── django.tf
│   └── nginx.tf
├── django/                  # Django application source
│   ├── Dockerfile
│   └── ...
├── nginx/                   # Nginx configuration
│   └── nginx.conf
└── ...
```

## Key Files

- **`terraform/main.tf`**: Defines the Terraform providers for Kubernetes and Docker.
- **`terraform/postgres.tf`**: Defines the PostgreSQL Kubernetes resources.
- **`terraform/django.tf`**: Defines the Django Kubernetes resources and builds the Docker image.
- **`terraform/nginx.tf`**: Defines the Nginx Kubernetes resources, including the Ingress.
- **`django/Dockerfile`**: The Dockerfile for the Django application.

## Common Commands

- **`terraform init`**: Initializes the Terraform workspace. Run this in the `terraform` directory.
- **`terraform plan`**: Creates an execution plan, showing what Terraform will do.
- **`terraform apply`**: Applies the changes required to reach the desired state of the configuration.
- **`terraform destroy`**: Destroys all the resources managed by Terraform.

## Makefile Commands

- **`make tf-init`**: Initializes the Terraform workspace.
- **`make tf-plan`**: Creates a Terraform execution plan.
- **`make tf-apply`**: Applies the Terraform configuration to the cluster.
- **`make tf-destroy`**: Destroys all resources managed by Terraform.
- **`make tf-clean`**: Removes any existing Kubernetes resources created by Terraform.
