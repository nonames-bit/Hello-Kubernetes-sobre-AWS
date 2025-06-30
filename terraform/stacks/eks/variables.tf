variable "region" { 
  description = "La región de AWS donde se desplegarán los recursos."
  type        = string
  default = "us-east-1"
}

variable "cluster_name" {
  description = "El nombre del clúster EKS."
  type        = string
}

variable "cluster_version" {
  description = "La versión de Kubernetes para el clúster EKS."
  type        = string
}

variable "tags" {
  description = "Un mapa de etiquetas para aplicar a los recursos del clúster EKS."
  type        = map(string)
}

variable "cluster_endpoint_public_access" {
  description = "Habilita o deshabilita el acceso público al endpoint del clúster EKS."
  type        = bool
}
