#!bin/bash
yum update -y
yum install -y httpd
git https://github.com/gabrielecirulli/2048.git
systemctl start httpd && systemctl enable httpd
