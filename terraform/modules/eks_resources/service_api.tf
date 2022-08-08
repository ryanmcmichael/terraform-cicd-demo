data "aws_ecr_image" "api_latest" {
  repository_name = "${var.client}/api"
  image_tag       = "${var.environment}-latest"
}

resource "kubernetes_deployment" "api_deployment" {
  depends_on = [kubernetes_namespace.sla]
  metadata {
    name      = "${var.environment}-api-deployment"
    namespace = kubernetes_namespace.sla.metadata.0.name
    labels = {
      app = "${var.environment}-api"
    }
  }

  spec {
    replicas = 3
    selector {
      match_labels = {
        app = "${var.environment}-api"
      }
    }
    template {
      metadata {
        labels = {
          app = "${var.environment}-api"
        }
      }
      spec {
        container {
          name  = "${var.environment}-api"
          image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${data.aws_ecr_image.api_latest.repository_name}:${data.aws_ecr_image.api_latest.image_tag}@${data.aws_ecr_image.api_latest.image_digest}"

          port {
            container_port = var.api_service_port
          }

          env {
            name  = "DB_HOST"
            value = var.db_host
          }

          env {
            name  = "DB_USER"
            value = var.db_username
          }

          env {
            name  = "DB_PASS"
            value = var.db_password
          }

          env {
            name  = "DB_PORT"
            value = var.db_port
          }

          env {
            name  = "DB"
            value = var.db_name
          }

          env {
            name  = "PORT"
            value = var.api_service_port
          }
        }
        service_account_name = "default"
      }
    }
  }
}

resource "kubernetes_service" "api_service" {
  depends_on = [
    kubernetes_deployment.api_deployment,
    kubernetes_namespace.sla
  ]

  metadata {
    labels = {
      app = "${var.environment}-api"
    }
    name      = "${var.environment}-api-service"
    namespace = kubernetes_namespace.sla.metadata.0.name
  }

  spec {
    port {
      name        = "${var.environment}-api"
      port        = var.api_service_port
      target_port = var.api_service_port
      protocol    = "TCP"
    }
    selector = {
      app = "${var.environment}-api"
    }
    type = "NodePort"
  }
}
