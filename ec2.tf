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

  owners = ["137112412989"] # Canonical -This is not the account no. but rather the AWS no.
}

resource "aws_instance" "public" {
  ami                         = data.aws_ami.amazonlinux.id
  instance_type               = "${var.instance-type}"
  subnet_id                   = aws_subnet.pub_sub[0].id
  vpc_security_group_ids      = [aws_security_group.pub-ec2-sg.id]
  associate_public_ip_address = true
  key_name                    = "${var.key-name}"
  user_data                   = file("userdata.sh")

  tags = {
    Name = "${var.env_code}-pub-ec2"
  }
}
#Private EC2 instance
resource "aws_instance" "private" {
  ami                         = data.aws_ami.amazonlinux.id
  instance_type               = "${var.instance-type}"
  subnet_id                   = aws_subnet.prt_sub[0].id
  vpc_security_group_ids      = [aws_security_group.prt-ec2-sg.id]
  key_name                    = "${var.key-name}"

  tags = {
    Name = "${var.env_code}-prt-ec2"
  }
}


