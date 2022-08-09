# Ingress

data "aws_availability_zones" "current" {
  # Exclusions only apply for this deployment - your mileage may vary
  exclude_names = ["us-east-1a", "us-east-1e", "us-east-1f"]
}

data "aws_acm_certificate" "ingress" {
  domain   = var.domain
  statuses = ["ISSUED"]
}

data "aws_route53_zone" "demo" {
  name         = "ryanmcmichael-demo.com."
  private_zone = false
}

/*resource "helm_release" "ingress_nginx" {
  depends_on = [kubernetes_namespace.sla]
  name       = "${var.environment}-ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "3.15.2"
  namespace  = kubernetes_namespace.sla.metadata.0.name
  timeout    = 600
  values     = [data.template_file.nginx-ingress-external-values.rendered]
}

resource "kubernetes_ingress_v1" "ingress" {
  depends_on             = [kubernetes_namespace.sla]
  wait_for_load_balancer = true

  metadata {
    labels = {
      app = "${var.environment}-ingress-nginx"
    }
    name      = "${var.environment}-ingress"
    namespace = kubernetes_namespace.sla.metadata.0.name
    annotations = {
      "kubernetes.io/ingress.class" : "nginx"
      "service.beta.kubernetes.io/aws-load-balancer-ssl-cert" : data.aws_acm_certificate.ingress.arn
      "service.beta.kubernetes.io/aws-load-balancer-ssl-ports" : "https"
      "service.beta.kubernetes.io/aws-load-balancer-backend-protocol" : "http"
      "service.beta.kubernetes.io/do-loadbalancer-hostname" : "${var.environment}-${var.client}.${var.domain}"
      "service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled" : "true"
    }

  }

  spec {

    sla_backend {
      service {
        name = kubernetes_service.web_service.metadata.0.name
        port {
          number = var.web_service_port
        }
      }
    }

    rule {
      http {
        path {
          backend {
            service {
              name = kubernetes_service.api_service.metadata.0.name
              port {
                number = var.api_service_port
              }
            }
          }
          path      = "/api"
          path_type = "Prefix"
        }
        path {
          backend {
            service {
              name = kubernetes_service.web_service.metadata.0.name
              port {
                number = var.web_service_port
              }
            }
          }
          path      = "/"
          path_type = "Prefix"
        }
      }
    }
  }
}

data "template_file" "nginx-ingress-external-values" {
  template = <<EOF
controller:
  service:
    targetPorts:
      https: 80
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-backend-protocol: http
      service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout: "60"
      service.beta.kubernetes.io/aws-load-balancer-ssl-cert: ${data.aws_acm_certificate.ingress.arn}
      service.beta.kubernetes.io/aws-load-balancer-ssl-negotiation-policy: ELBSecurityPolicy-TLS-1-2-2017-01
      service.beta.kubernetes.io/aws-load-balancer-ssl-ports: https
      service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
  config:
    server-tokens: "false"
    ssl-redirect: "true"
    use-forwarded-headers: "true"
    use-proxy-protocol: "false"
    enable-vts-status: "true"
    proxy-real-ip-cidr: 0.0.0.0/0
    proxy-body-size: 5G
  publishService:
    enabled: true
slaBackend:
  enabled: false
metrics:
  enabled: true
EOF
}
*/





resource "helm_release" "ingress_nginx" {
  depends_on = [kubernetes_namespace.sla]
  name       = "${var.client}-${var.environment}-ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  #version    = "3.15.2"
  namespace  = kubernetes_namespace.sla.metadata.0.name
  timeout    = 600
  values     = [data.template_file.nginx-ingress-external-values.rendered]
}

resource "kubernetes_ingress_v1" "ingress_nginx" {
  depends_on             = [kubernetes_namespace.sla]
  wait_for_load_balancer = true

  metadata {
    labels = {
      app = "${var.client}-${var.environment}-ingress-nginx"
    }
    name      = "${var.client}-${var.environment}-exposed-ingress"
    namespace = kubernetes_namespace.sla.metadata.0.name
    annotations = {
      "kubernetes.io/ingress.class" : "nginx"
      "service.beta.kubernetes.io/aws-load-balancer-ssl-cert" : data.aws_acm_certificate.ingress.arn
      "service.beta.kubernetes.io/aws-load-balancer-ssl-ports" : "https"
      "service.beta.kubernetes.io/aws-load-balancer-backend-protocol" : "http"
      "service.beta.kubernetes.io/do-loadbalancer-hostname" : "${var.environment}-${var.client}.${var.domain}"
      "service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled" : "true"
    }

  }

  spec {
    rule {
      http {
        path {
          backend {
            service {
              name = kubernetes_service.api_service.metadata.0.name
              port {
                number = var.api_service_port
              }
            }
          }
          path      = "/api"
          path_type = "Prefix"
        }
        path {
          backend {
            service {
              name = kubernetes_service.web_service.metadata.0.name
              port {
                number = var.web_service_port
              }
            }
          }
          path      = "/"
          path_type = "Prefix"
        }
      }
    }
  }
}

data "template_file" "nginx-ingress-external-values" {
  template = <<EOF
controller:
  service:
    targetPorts:
      https: 80
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-backend-protocol: http
      service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout: "60"
      service.beta.kubernetes.io/aws-load-balancer-ssl-cert: ${data.aws_acm_certificate.ingress.arn}
      service.beta.kubernetes.io/aws-load-balancer-ssl-negotiation-policy: ELBSecurityPolicy-TLS-1-2-2017-01
      service.beta.kubernetes.io/aws-load-balancer-ssl-ports: https
      service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
  config:
    server-tokens: "false"
    ssl-redirect: "true"
    use-forwarded-headers: "true"
    use-proxy-protocol: "false"
    enable-vts-status: "true"
    proxy-real-ip-cidr: 0.0.0.0/0
    proxy-body-size: 5G
  publishService:
    enabled: true
slaBackend:
  enabled: false
metrics:
  enabled: true
data:
  error-log-level: info
EOF
}

data "aws_resourcegroupstaggingapi_resources" "ingress_cm" {
  depends_on = [kubernetes_ingress_v1.ingress_nginx]
  resource_type_filters = ["elasticloadbalancing:loadbalancer"]

  tag_filter {
    key    = "kubernetes.io/service-name"
    values = ["${var.client}/${var.client}-${var.environment}-ingress-nginx-controller"]
  }
}

data "aws_elb" "ingress_cm" {
  name = element(split("/", data.aws_resourcegroupstaggingapi_resources.ingress_cm.resource_tag_mapping_list[0].resource_arn), length(data.aws_resourcegroupstaggingapi_resources.ingress_cm.resource_tag_mapping_list[0].resource_arn))
}

resource "aws_route53_record" "ingress_public" {
  zone_id = data.aws_route53_zone.demo.id
  name    = "${var.environment}-${var.client}"
  type    = "CNAME"
  ttl     = "60"

  records        = [data.aws_elb.ingress_cm.dns_name]
}
