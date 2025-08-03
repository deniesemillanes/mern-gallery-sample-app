# 3
# EC2 Instances

# 1. NAT EC2 Instance in the public subnet
resource "aws_instance" "nat_instance" {
  ami                         = "ami-08a6efd148b1f7504"     # Amazon Linux 2023, ec2-user
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  key_name                    = var.key_name                  # NEED TO ACCESS THE IP USING SSH Replace with  key_name in variable 
  associate_public_ip_address = true                        # Auto-assign public IP
  source_dest_check = false # Required for NAT behavior

  user_data = <<-EOF
              #!/bin/bash
              sudo yum install iptables-services -y
              sudo systemctl enable iptables
              sudo systemctl start iptables
              echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/custom-ip-forwarding.conf
              sudo sysctl -p /etc/sysctl.d/custom-ip-forwarding.conf
              sudo /sbin/iptables -t nat -A POSTROUTING -o enX0 -j MASQUERADE
              sudo /sbin/iptables -F FORWARD
              sudo service iptables save
              EOF

  tags = {
    Name = "NAT-Instance"
  }
    # for calling sg
    # vpc_security_group_ids = [aws_security_group.<sg-name>.id]
    # by calling sg, you are also attaching vpc since sg is already attach to vpc 
  vpc_security_group_ids = [aws_security_group.nat_sg.id]
}


#2 BACKEND EC2 Instances (Private)
resource "aws_instance" "backend_ec2" {
  count                       = 3
  ami                         = "ami-08a6efd148b1f7504" 
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private_subnet.id
  key_name                    = var.key_name
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.backend_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install git -y
    sudo git config --global user.name "deniesemillanes"
    sudo git config --global user.email "deniesemillanes@gmail.com"
    sudo yum install docker -y
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ec2-user
  EOF

  tags = {
    Name = "backend-ec2-${count.index + 1}"
  }
}

#3 MONGODB EC2 (Private)
resource "aws_instance" "mongodb_ec2" {
  ami                         = "ami-08a6efd148b1f7504" 
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private_subnet.id
  key_name                    = var.key_name
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.mongodb_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install git -y
    sudo git config --global user.name "deniesemillanes"
    sudo git config --global user.email "deniesemillanes@gmail.com"
    sudo yum install docker -y
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ec2-user
    sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
  EOF

  tags = {
    Name = "mongodb-ec2"
  }
}

#4 PROXY EC2 (Public)
resource "aws_instance" "proxy_ec2" {
  ami                         = "ami-08a6efd148b1f7504" 
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  key_name                    = var.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.proxy_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install git -y
    sudo git config --global user.name "deniesemillanes"
    sudo git config --global user.email "deniesemillanes@gmail.com"
    sudo yum install nginx -y
    sudo systemctl start nginx
    sudo systemctl enable nginx
  EOF

  tags = {
    Name = "proxy-ec2"
  }
}

#5 FRONTEND EC2 (Public)
resource "aws_instance" "frontend_ec2" {
  count                       = 2
  ami                         = "ami-08a6efd148b1f7504" 
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  key_name                    = var.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.frontend_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install git -y
    sudo git config --global user.name "deniesemillanes"
    sudo git config --global user.email "deniesemillanes@gmail.com"
    sudo yum install docker -y
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ec2-user
    sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
  EOF

  tags = {
    Name = "frontend-ec2-${count.index + 1}"
  }
}
