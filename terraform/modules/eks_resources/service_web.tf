data "aws_ecr_image" "web_latest" {
  repository_name = "${var.client}/web" #TODO: change this
  image_tag       = "${var.environment}-latest"
}

/*resource "kubernetes_deployment" "web_deployment" {
  depends_on = [kubernetes_namespace.sla]
  metadata {
    name      = "${var.environment}-web-deployment"
    namespace = kubernetes_namespace.sla.metadata.0.name
    labels = {
      app = "${var.environment}-web"
    }
  }

  spec {
    replicas = 3
    selector {
      match_labels = {
        app = "${var.environment}-web"
      }
    }
    template {
      metadata {
        labels = {
          app = "${var.environment}-web"
        }
      }
      spec {
        container {
          name  = "${var.environment}-web"
          image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${data.aws_ecr_image.web_latest.repository_name}:${data.aws_ecr_image.web_latest.image_tag}@${data.aws_ecr_image.web_latest.image_digest}"

          port {
            container_port = var.web_service_port
          }

          env {
            name  = "API_HOST"
            value = "https://${var.client}-${var.environment}.${var.domain}/api"
          }

          env {
            name  = "PORT"
            value = var.web_service_port
          }
        }
        service_account_name = "default"
      }
    }
  }
}

resource "kubernetes_service" "web_service" {
  depends_on = [
    kubernetes_deployment.web_deployment,
    kubernetes_namespace.sla
  ]

  metadata {
    labels = {
      app = "${var.environment}-web"
    }
    name      = "${var.environment}-web-service"
    namespace = kubernetes_namespace.sla.metadata.0.name
  }

  spec {
    port {
      name        = "${var.environment}-web"
      port        = var.web_service_port
      target_port = var.web_service_port
      protocol    = "TCP"
    }
    selector = {
      app = "${var.environment}-web"
    }
    type = "NodePort"
  }
}*/
