#!/bin/bash
yum update -y
yum install -y httpd
yum install -y git

# Clone the 2048 repository
git clone https://github.com/gabrielecirulli/2048.git

# Move the cloned files to the appropriate directory
mv 2048/* /var/www/html/

# Start and enable the Apache web server
systemctl start httpd && systemctl enable httpd
