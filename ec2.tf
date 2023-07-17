#--------------------------------------------------------------------------------------------------------------------------
# EC2 SECURITY GROUP
#-------------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "pub-ec2-sg" {
  name        = "${var.env_code}-public-sg"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.env_vpc.id

  ingress {
    description = "SSH from the internet"
    from_port   = 22
    to_port     = 22
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

#-----------------------------------------------------------------------------------------------------------------------
# EC2 RESOURCE
#-----------------------------------------------------------------------------------------------------------------------
resource "aws_instance" "public" {
  ami                         = "ami-06464c878dbe46da4"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.pub_sub[0].id
  vpc_security_group_ids      = [aws_security_group.pub-ec2-sg.id]
  associate_public_ip_address = true
  key_name                    = "Public-key"

  tags = {
    Name = "${var.env_code}-pub-ec2"
  }
}


