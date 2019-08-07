variable "aws_region" {
  description = "Región de AWS en la que lanzar los servidores"
  default     = "us-east-1"
}
variable "project_name" {
  description = "Nombre del proyecto"
  default     = "calculator"
}
variable "environment" {
  description = "Nombre del entorno"
  default     = "dev"
}