provider "aws" {
  region = "us-east-1"  # Update to your AWS region
}

# Create a security group for Jenkins EC2 instance
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-security-group"
  description = "Allow SSH and Jenkins HTTP access"
  vpc_id      = "vpc-048c4ffc46defb288"# Replace with your VPC ID if you don't manage subnet with Terraform

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["172.31.32.0/20"] # Replace YOUR_IP with your IP for security, or 0.0.0.0/0 for testing (not recommended for production)
  }

  ingress {
    description = "Allow Jenkins HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["54.83.127.55/32"] # Same as above, restrict access to your IP or allowed IP range
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-security-group"
  }
}


# Jenkins EC2 instance
resource "aws_instance" "jenkins_server" {
  ami                    = "ami-0c94855ba95c71c99"  # Update for your region
  instance_type          = "t2.micro"
  private_ip             = "172.31.32.10"  # Update this to match your subnet's CIDR
  key_name               = "web-game-key"  # Replace with your key pair
  subnet_id              = "subnet-053ad24e3818e1607"
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo amazon-linux-extras install java-openjdk11 -y
    sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
    sudo yum install jenkins -y
    sudo systemctl start jenkins
    sudo systemctl enable jenkins
  EOF

  tags = {
    Name = "Jenkins-Server"
  }

  associate_public_ip_address = true  # Add this if subnet is public and you want to access Jenkins directly; else use bastion/SSH tunnel
}
