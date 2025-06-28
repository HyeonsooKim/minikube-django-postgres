# Minikube Django PostgreSQL with Terraform

This project sets up a single-cluster Kubernetes environment using `Minikube`, `Django`, `PostgreSQL`, and `Nginx`, all managed by `Terraform`.

## Prerequisites

- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- [Docker](https://docs.docker.com/get-docker/)
- [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

## Setup and Deployment

1.  **Start Minikube:**
    ```bash
    minikube start
    ```

2.  **Initialize and Apply with Make:**
    The `Makefile` provides a convenient way to manage the project. To deploy everything, simply run:
    ```bash
    make tf-apply
    ```
    This single command will:
    - Initialize Terraform.
    - Build the Django Docker image.
    - Deploy PostgreSQL, Django, and Nginx.
    - Set up all necessary services, secrets, and ingress.

3.  **Access the application:**
    Find your Minikube IP:
    ```bash
    minikube ip
    ```
    You can now access the application in your browser at `http://<minikube-ip>`.

## Cleanup

To tear down all the resources, use the `make` command:
```bash
make tf-destroy
```