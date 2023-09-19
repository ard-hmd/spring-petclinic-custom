provider "kubernetes" {
  config_path = "~/.kube/config" # Mettez le chemin correct vers votre fichier de configuration kubeconfig
}

# k8s/init-namespace/01-namespace.yaml
resource "kubernetes_namespace" "spring_petclinic" {
  metadata {
    name = var.namespace
  }
}

# k8s/init-services/02-config-map.yaml
resource "kubernetes_config_map" "petclinic_config" {
  metadata {
    name      = "petclinic-config"
    namespace = "spring-petclinic"
  }

  data = {
    "application.yaml" = <<-EOF
      server:
        shutdown: graceful
        lifecycle:
          timeout-per-shutdown-phase: 15
        port: 8080
        compression:
          enabled: true
          mime-types: application/json,text/css,application/javascript
          min-response-size: 2048

      wavefront:
        application:
          name: spring-petclinic-k8s
        freemium-account: true

      # Logging
      logging.level.org.springframework: INFO

      # Metrics
      management:
        endpoint:
          health:
            probes:
              enabled: true
        health:
          livenessState:
            enabled: true
          readinessState:
            enabled: true
          restart:
            enabled: true
          metrics:
            enabled: true
          prometheus:
            enabled: true
        endpoints:
          web:
            exposure:
              include: '*'
        metrics:
          export:
            prometheus:
              enabled: true
            wavefront:
              enabled: true

      customers-service-id: http://customers-service.spring-petclinic.svc.cluster.local:8080
      visits-service-id: http://visits-service.spring-petclinic.svc.cluster.local:8080

      spring:
        datasource:
          schema: classpath*:db/mysql/schema.sql
          data: classpath*:db/mysql/data.sql
          platform: mysql
          initialization-mode: always

        jpa:
          show-sql: true
          hibernate:
            ddl-auto: none
            generate-ddl: false
        sleuth:
          sampler:
            probability: 1.0
          config:
            # Allow the microservices to override the remote properties with their own System properties or config file
            allow-override: true
            # Override configuration with any local property source
            override-none: true
        messages:
          basename: messages/messages
        cloud:
          kubernetes:
            discovery:
              enabled: true
          loadbalancer:
            ribbon:
              enabled: false
          gateway:
            x-forwarded:  
              enabled: true 
              for-enabled: true 
              proto-enabled: true 
              host-append: false  
              port-append: false  
              proto-append: false
            routes:
              - id: vets-service
                uri: http://vets-service.spring-petclinic.svc.cluster.local:8080
                predicates:
                  - Path=/api/vet/**
                filters:
                  - StripPrefix=2
              - id: visits-service
                uri: http://visits-service.spring-petclinic.svc.cluster.local:8080
                predicates:
                  - Path=/api/visit/**
                filters:
                  - StripPrefix=2
              - id: customers-service
                uri: http://customers-service.spring-petclinic.svc.cluster.local:8080
                predicates:
                  - Path=/api/customer/**
                filters:
                  - StripPrefix=2
      vets:
        cache:
          ttl: 60
          heap-size: 101
    EOF
  }
}

# k8s/init-services/03-role.yaml
resource "kubernetes_role" "namespace_reader" {
  metadata {
    name      = "namespace-reader"
    namespace = var.namespace
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps", "pods", "services", "endpoints", "secrets"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding" "namespace_reader_binding" {
  metadata {
    name      = "namespace-reader-binding"
    namespace = var.namespace
  }

  subject {
    kind      = "ServiceAccount"
    name      = "default"
    api_group = ""
  }

  role_ref {
    kind      = "Role"
    name      = kubernetes_role.namespace_reader.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }
}

# k8s/init-services/05-api-gateway-service.yaml
resource "kubernetes_service" "api_gateway" {
  metadata {
    name      = "api-gateway"
    namespace = var.namespace
    labels = {
      app = "api-gateway"
    }

    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-backend-protocol" = "http"
      "service.beta.kubernetes.io/aws-load-balancer-tls-cert"         = var.acm_certificate_arn
      "service.beta.kubernetes.io/aws-load-balancer-tls-ports"        = "https"
    }
  }

  spec {
    selector = {
      app = "api-gateway"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 8080
    }

    port {
      name        = "https"
      port        = 443
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}

# k8s/init-services/06-customers-service-service.yaml
resource "kubernetes_service" "customers_service" {
  metadata {
    name      = "customers-service"
    namespace = var.namespace
    labels = {
      app = "customers-service"
    }
  }

  spec {
    port {
      name        = "http"
      port        = 8080
      target_port = 8080
    }

    selector = {
      app = "customers-service"
    }
  }
}

# k8s/init-services/07-vets-service-service.yaml
resource "kubernetes_service" "vets_service" {
  metadata {
    name      = "vets-service"
    namespace = var.namespace
    labels = {
      app = "vets-service"
    }
  }

  spec {
    port {
      name        = "http"
      port        = 8080
      target_port = 8080
    }

    selector = {
      app = "vets-service"
    }
  }
}

# k8s/init-services/08-visits-service-service.yaml
resource "kubernetes_service" "visits_service" {
  metadata {
    name      = "visits-service"
    namespace = var.namespace
    labels = {
      app = "visits-service"
    }
  }

  spec {
    port {
      name        = "http"
      port        = 8080
      target_port = 8080
    }

    selector = {
      app = "visits-service"
    }
  }
}

# k8s/api-gateway-deployment.yaml
resource "kubernetes_deployment" "api_gateway" {
  metadata {
    name      = "api-gateway"
    namespace = var.namespace
    labels = {
      app = "api-gateway"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "api-gateway"
      }
    }

    template {
      metadata {
        labels = {
          app = "api-gateway"
        }
      }

      spec {
        container {
          image = "${var.repository_prefix}/spring-petclinic-cloud-api-gateway:latest"
          name  = "api-gateway"

          image_pull_policy = "Always"

          liveness_probe {
            http_get {
              path = "/actuator/health/liveness"
              port = 8080
            }
            initial_delay_seconds = 90
            period_seconds        = 5
          }

          readiness_probe {
            http_get {
              path = "/actuator/health/readiness"
              port = 8080
            }
            initial_delay_seconds = 15
          }

          lifecycle {
            pre_stop {
              exec {
                command = ["sh", "-c", "sleep 10"]
              }
            }
          }

          resources {
            limits = {
              memory = "1Gi"
              cpu = "500m"
            }
            requests = {
              cpu    = "500m"
              memory = "1Gi"
            }
          }

          env {
            name  = "SPRING_PROFILES_ACTIVE"
            value = "kubernetes"
          }

          env {
            name  = "MANAGEMENT_METRICS_EXPORT_WAVEFRONT_URI"
            value = "proxy://wavefront-proxy.spring-petclinic.svc.cluster.local:2878"
          }

          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_secret" "customers_db_mysql_secret" {
  metadata {
    name = "customers-db-mysql-secret"
    namespace = var.namespace
  }

  data = {
    "mysql-root-password" = var.customers_db_password
  }
}

# k8s/customers-service-deployment.yaml
resource "kubernetes_deployment" "customers_service" {
  metadata {
    name      = "customers-service"
    namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "customers-service"
      }
    }

    template {
      metadata {
        labels = {
          app = "customers-service"
        }
      }

      spec {
        container {
          name  = "customers-service"
          image = "${var.repository_prefix}/spring-petclinic-cloud-customers-service:latest"

          liveness_probe {
            http_get {
              path = "/actuator/health/liveness"
              port = 8080
            }
            initial_delay_seconds = 90
            period_seconds        = 5
          }

          readiness_probe {
            http_get {
              path = "/actuator/health/readiness"
              port = 8080
            }
            initial_delay_seconds = 15
          }

          lifecycle {
            pre_stop {
              exec {
                command = ["sh", "-c", "sleep 10"]
              }
            }
          }

          resources {
            limits = {
              memory = "1Gi"
              cpu = "500m"
            }
            requests = {
              cpu    = "500m"
              memory = "1Gi"
            }
          }

          env {
            name  = "SPRING_PROFILES_ACTIVE"
            value = "kubernetes"
          }

          env {
            name  = "SPRING_DATASOURCE_URL"
            value = "jdbc:mysql://${var.customers_db_host}:3306/${var.customers_db_name}?queryInterceptors=brave.mysql8.TracingQueryInterceptor&exceptionInterceptors=brave.mysql8.TracingExceptionInterceptor&zipkinServiceName=customers-db"
          }

          env {
            name  = "SPRING_DATASOURCE_USERNAME"
            value = "admin"
          }

          env {
            name = "SPRING_DATASOURCE_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.customers_db_mysql_secret.metadata[0].name
                key  = "mysql-root-password"
              }
            }
          }

          env {
            name  = "MANAGEMENT_METRICS_EXPORT_WAVEFRONT_URI"
            value = "proxy://wavefront-proxy.spring-petclinic.svc.cluster.local:2878"
          }

          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_secret" "vets_db_mysql_secret" {
  metadata {
    name = "vets-db-mysql-secret"
    namespace = var.namespace
  }

  data = {
    "mysql-root-password" = var.vets_db_password
  }
}

# k8s/vets-service-deployment.yaml
resource "kubernetes_deployment" "vets_service" {
  metadata {
    name      = "vets-service"
    namespace = var.namespace
    labels = {
      app = "vets-service"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "vets-service"
      }
    }

    template {
      metadata {
        labels = {
          app = "vets-service"
        }
      }

      spec {
        container {
          name  = "vets-service"
          image = "${var.repository_prefix}/spring-petclinic-cloud-vets-service:latest"

          liveness_probe {
            http_get {
              path = "/actuator/health/liveness"
              port = 8080
            }
            initial_delay_seconds = 90
            period_seconds        = 5
          }

          readiness_probe {
            http_get {
              path = "/actuator/health/readiness"
              port = 8080
            }
            initial_delay_seconds = 15
          }

          lifecycle {
            pre_stop {
              exec {
                command = ["sh", "-c", "sleep 10"]
              }
            }
          }

          resources {
            limits = {
              memory = "1Gi"
            }
            requests = {
              cpu    = "2000m"
              memory = "1Gi"
            }
          }

          env {
            name  = "SPRING_PROFILES_ACTIVE"
            value = "kubernetes"
          }

          env {
            name  = "SPRING_DATASOURCE_URL"
            value = "jdbc:mysql://${var.vets_db_host}:3306/${var.vets_db_name}?queryInterceptors=brave.mysql8.TracingQueryInterceptor&exceptionInterceptors=brave.mysql8.TracingExceptionInterceptor&zipkinServiceName=vets-db"
          }

          env {
            name  = "SPRING_DATASOURCE_USERNAME"
            value = "admin"
          }

          env {
            name = "SPRING_DATASOURCE_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.vets_db_mysql_secret.metadata[0].name
                key  = "mysql-root-password"
              }
            }
          }

          env {
            name  = "MANAGEMENT_METRICS_EXPORT_WAVEFRONT_URI"
            value = "proxy://wavefront-proxy.spring-petclinic.svc.cluster.local:2878"
          }

          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_secret" "visits_db_mysql_secret" {
  metadata {
    name = "visits-db-mysql-secret"
    namespace = var.namespace
  }

  data = {
    "mysql-root-password" = var.visits_db_password
  }
}


# k8s/visits-service-deployment.yaml
resource "kubernetes_deployment" "visits_service" {
  metadata {
    name      = "visits-service"
    namespace = var.namespace
    labels = {
      app = "visits-service"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "visits-service"
      }
    }

    template {
      metadata {
        labels = {
          app = "visits-service"
        }
      }

      spec {
        container {
          image = "${var.repository_prefix}/spring-petclinic-cloud-visits-service:latest"
          name  = "visits-service"

          resources {
            limits = {
              memory = "1Gi"
              cpu = "500m"
            }
            requests = {
              cpu    = "500m"
              memory = "1Gi"
            }
          }

          liveness_probe {
            http_get {
              path = "/actuator/health/liveness"
              port = 8080
            }
            initial_delay_seconds = 90
            period_seconds        = 5
          }

          readiness_probe {
            http_get {
              path = "/actuator/health/readiness"
              port = 8080
            }
            initial_delay_seconds = 15
          }

          lifecycle {
            pre_stop {
              exec {
                command = ["sh", "-c", "sleep 10"]
              }
            }
          }

          env {
            name  = "SPRING_PROFILES_ACTIVE"
            value = "kubernetes"
          }

          env {
            name  = "SPRING_DATASOURCE_URL"
            value = "jdbc:mysql://${var.visits_db_host}:3306/${var.visits_db_name}?queryInterceptors=brave.mysql8.TracingQueryInterceptor&exceptionInterceptors=brave.mysql8.TracingExceptionInterceptor&zipkinServiceName=visits-db"
          }

          env {
            name  = "SPRING_DATASOURCE_USERNAME"
            value = "admin"
          }

          env {
            name = "SPRING_DATASOURCE_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.visits_db_mysql_secret.metadata[0].name
                key  = "mysql-root-password"
              }
            }
          }

          env {
            name  = "MANAGEMENT_METRICS_EXPORT_WAVEFRONT_URI"
            value = "proxy://wavefront-proxy.spring-petclinic.svc.cluster.local:2878"
          }

          port {
            container_port = 8080
          }
        }
      }
    }
  }
}
