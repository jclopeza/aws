# Indicamos el provider y los datos de acceso
provider "aws" {
  region = "${var.aws_region}"
}

# Creamos una VPC, el nombre debe estar parametrizado porque necesitaremos varias VPC
resource "aws_vpc" "vpc" {
  cidr_block = "192.168.0.0/16"
  tags = {
    Name = "${var.project_name}-${var.environment}"
  }
}

# Creación de las subredes
resource "aws_subnet" "private-1" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "192.168.1.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  tags = {
    Name = "${var.project_name}-${var.environment}-private-1"
  }
}
resource "aws_subnet" "private-2" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "192.168.2.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  tags = {
    Name = "${var.project_name}-${var.environment}-private-2"
  }
}
# En las subredes que serán públicas, habilitamos la asignación automática de IP pública
resource "aws_subnet" "public-1" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "192.168.3.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[2]}"
  tags = {
    Name = "${var.project_name}-${var.environment}-public-1"
  }
  map_public_ip_on_launch = true
}
resource "aws_subnet" "public-2" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "192.168.4.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[3]}"
  tags = {
    Name = "${var.project_name}-${var.environment}-public-2"
  }
  map_public_ip_on_launch = true
}