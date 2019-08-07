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

# Creamos un nuevo Internet Gateway y lo asociamos a nuestra VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name = "${var.project_name}-${var.environment}-igw"
  }
}

# Creación de las tablas de rutas. Por defecto se crea y se asocia una a la VPC
# que ya hemos creado. Pero creamos dos nuevas. A una de ellas le damos salida a internet
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name = "${var.project_name}-${var.environment}-private"
  }
}
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
  tags = {
    Name = "${var.project_name}-${var.environment}-public"
  }
}

# Asociamos las subredes a las tablas de rutas
resource "aws_route_table_association" "private-1-private" {
  subnet_id      = "${aws_subnet.private-1.id}"
  route_table_id = "${aws_route_table.private.id}"
}
resource "aws_route_table_association" "private-2-private" {
  subnet_id      = "${aws_subnet.private-2.id}"
  route_table_id = "${aws_route_table.private.id}"
}
resource "aws_route_table_association" "public-1-public" {
  subnet_id      = "${aws_subnet.public-1.id}"
  route_table_id = "${aws_route_table.public.id}"
}
resource "aws_route_table_association" "public-2-public" {
  subnet_id      = "${aws_subnet.public-2.id}"
  route_table_id = "${aws_route_table.public.id}"
}

# Creación de security groups para asociar a las instancias
resource "aws_security_group" "allow_8080" {
  vpc_id      = "${aws_vpc.vpc.id}"
  name        = "allow_8080"
  description = "Allow 8080 inbound traffic"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_8080"
  }
}
resource "aws_security_group" "allow_22" {
  vpc_id      = "${aws_vpc.vpc.id}"
  name        = "allow_22"
  description = "Allow 22 inbound traffic"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_22"
  }
}
resource "aws_security_group" "allow_3306" {
  vpc_id      = "${aws_vpc.vpc.id}"
  name        = "allow_3306"
  description = "Allow 3306 inbound traffic"
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_3306"
  }
}

# Creamos una clave en AWS para acceder a las instancias EC2
resource "aws_key_pair" "akp" {
  key_name   = "${var.project_name}-${var.environment}"
  public_key = "${file(var.public_key_path)}"
}

# Creación de las instancias
resource "aws_instance" "front" {
  ami = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.instance_type}"
  key_name = "${aws_key_pair.akp.id}"
  subnet_id = "${aws_subnet.public-1.id}"
  vpc_security_group_ids = [
      "${aws_security_group.allow_22.id}",
      "${aws_security_group.allow_8080.id}"
    ]
  tags = {
    Name = "${var.project_name}-${var.environment}-front"
  }
  connection {
    host        = "${self.public_ip}"
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file(var.private_key_path)}"
  }
  provisioner "remote-exec" {
    inline = [
        "sudo apt-get update"
    ]
  }
  provisioner "local-exec" {
    command = "ansible-playbook -u ubuntu -i '${self.public_ip},' --private-key ${var.private_key_path} playbook-tomcat8.yml --ssh-common-args='-o StrictHostKeyChecking=no'"
  }
}
resource "aws_instance" "webservice" {
  ami = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.instance_type}"
  key_name = "${aws_key_pair.akp.id}"
  subnet_id = "${aws_subnet.public-2.id}"
  vpc_security_group_ids = [
      "${aws_security_group.allow_22.id}",
      "${aws_security_group.allow_8080.id}"
    ]
  tags = {
    Name = "${var.project_name}-${var.environment}-webservice"
  }
  connection {
    host        = "${self.public_ip}"
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file(var.private_key_path)}"
  }
  provisioner "remote-exec" {
    inline = [
        "sudo apt-get update"
    ]
  }
  provisioner "local-exec" {
    command = "ansible-playbook -u ubuntu -i '${self.public_ip},' --private-key ${var.private_key_path} playbook-axis2.yml --ssh-common-args='-o StrictHostKeyChecking=no'"
  }
}