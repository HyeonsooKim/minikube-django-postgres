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

2.  **Enable Ingress:**
    ```bash
    minikube addons enable ingress
    ```

3.  **Point Docker to Minikube's Docker daemon:**
    ```bash
    eval $(minikube docker-env)
    ```

4.  **Initialize Terraform:**
    Navigate to the `terraform` directory and run:
    ```bash
    cd terraform
    terraform init
    ```

5.  **Apply the Terraform configuration:**
    ```bash
    terraform apply
    ```
    This command will:
    - Build the Django Docker image.
    - Deploy PostgreSQL, Django, and Nginx to your Minikube cluster.
    - Set up the necessary services, secrets, and ingress.

6.  **Access the application:**
    Find your Minikube IP:
    ```bash
    minikube ip
    ```
    You can now access the application in your browser at `http://<minikube-ip>`.

## Cleanup

To tear down all the resources created by Terraform, run:
```bash
terraform destroy
```