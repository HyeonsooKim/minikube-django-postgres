resource "docker_image" "django_image" {
  name = "minikube-django:latest"
  build {
    context    = "/home/hwangjongtaek/projects/k8s/simple-app/django"
    dockerfile = "Dockerfile"
  }
}

resource "kubernetes_deployment" "django" {
  metadata {
    name = "django"
  }
  spec {
    replicas = 3
    selector {
      match_labels = {
        app = "django"
      }
    }
    template {
      metadata {
        labels = {
          app = "django"
        }
      }
      spec {
        container {
          name  = "django"
          image = docker_image.django_image.name
          image_pull_policy = "Never"
          port {
            container_port = 8000
          }
          env {
            name  = "DB_HOST"
            value = "postgres"
          }
          env {
            name = "DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres_secret.metadata[0].name
                key  = "POSTGRES_PASSWORD"
              }
            }
          }
          env {
            name  = "DB_NAME"
            value = "postgres"
          }
          env {
            name  = "DB_USER"
            value = "postgres"
          }
          env {
            name  = "DJANGO_SUPERUSER_USERNAME"
            value = "admin"
          }
          env {
            name = "DJANGO_SUPERUSER_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres_secret.metadata[0].name
                key  = "POSTGRES_PASSWORD"
              }
            }
          }
          env {
            name  = "DJANGO_SUPERUSER_EMAIL"
            value = "admin@example.com"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "django" {
  metadata {
    name = "django"
  }
  spec {
    selector = {
      app = kubernetes_deployment.django.spec[0].template[0].metadata[0].labels.app
    }
    port {
      port        = 8000
      target_port = 8000
    }
    type = "ClusterIP"
  }
}
