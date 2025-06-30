variable "vpc_name" {
  description = "El nombre para la VPC."
  type        = string
}

variable "vpc_cidr" {
  description = "El bloque CIDR para la VPC."
  type        = string
}

variable "azs" {
  description = "Una lista de Zonas de Disponibilidad (AZs) a usar."
  type        = list(string)
}

variable "private_subnets" {
  description = "Una lista de bloques CIDR para las subredes privadas."
  type        = list(string)
}

variable "public_subnets" {
  description = "Una lista de bloques CIDR para las subredes públicas."
  type        = list(string)
}

variable "tags" {
  description = "Un mapa de etiquetas para aplicar a los recursos de la VPC."
  type        = map(string)
  default     = {}
}