variable "instance_type" {
  description = "Tipo de instancia a crear"
  default     = "t2.micro"
}
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
variable "public_key_path" {
  description = "Ubicación de la clave pública que será instalada en los hosts remotos"
  default     = "~/.ssh/id_rsa.pub"
}
variable "private_key_path" {
  description = "Ubicación de la clave privada para los provisioners"
  default     = "~/.ssh/id_rsa"
}
