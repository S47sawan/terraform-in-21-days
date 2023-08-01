#--------------------------------------------------------------------------------------------------------------------------
# EC2 SECURITY GROUP
#-------------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "pub-ec2-sg" {
  name        = "${var.env_code}-public-sg"
  description = "Allow SSH inbound traffic"
  vpc_id      = data.terraform_remote_state.level1.outputs.vpc_id

  ingress {
    description = "SSH from the internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http traffic from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.env_code}-pub-ec2-sg"
  }
}

# Private instance security group
resource "aws_security_group" "prt-ec2-sg" {
  name        = "${var.env_code}-private-sg"
  description = "Allow SSH inbound traffic"
  vpc_id      = data.terraform_remote_state.level1.outputs.vpc_id

  ingress {
    description = "SSH from the internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.level1.outputs.vpc_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.env_code}-prt-ec2-sg"
  }
}
#-----------------------------------------------------------------------------------------------------------------------
# EC2 RESOURCE
#-----------------------------------------------------------------------------------------------------------------------
data "aws_ami" "amazonlinux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"] # Canonical -This is not the account no. but rather the AWS no.
}
resource "aws_instance" "public" {
  ami                         = data.aws_ami.amazonlinux.id
  instance_type               = var.instance_type
  subnet_id                   = data.terraform_remote_state.level1.outputs.public_subnet_id[1]
  vpc_security_group_ids      = [aws_security_group.pub-ec2-sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name
  user_data                   = file("userdata.sh")

  tags = {
    Name = "${var.env_code}-pub-ec2"
  }
}
#Private EC2 instance
resource "aws_instance" "private" {
  ami                    = data.aws_ami.amazonlinux.id
  instance_type          = var.instance_type
  subnet_id              = data.terraform_remote_state.level1.outputs.private_subnet_id[1]
  vpc_security_group_ids = [aws_security_group.prt-ec2-sg.id]
  key_name               = var.key_name

  tags = {
    Name = "${var.env_code}-prt-ec2"
  }
}


