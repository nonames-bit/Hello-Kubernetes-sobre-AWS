variable "cluster_name" {
  description = "El nombre del clúster EKS."
  type        = string
}

variable "cluster_version" {
  description = "La versión de Kubernetes para el clúster EKS."
  type        = string
}

variable "vpc_id" {
  description = "El ID de la VPC donde se desplegará el clúster EKS."
  type        = string
}

variable "subnet_ids" {
  description = "Una lista de IDs de subredes para el clúster EKS."
  type        = list(string)
}

variable "tags" {
  description = "Un mapa de etiquetas para aplicar a los recursos del clúster EKS."
  type        = map(string)
  default     = {}
}

variable "cluster_endpoint_public_access" {
  description = "Habilita o deshabilita el acceso público al endpoint del clúster EKS."
  type        = bool
  default     = false # Generalmente falso para mayor seguridad, a menos que se necesite.
}
