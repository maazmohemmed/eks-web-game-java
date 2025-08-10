# main.tf

terraform {
  required_version = ">= 1.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# ECR repo
resource "aws_ecr_repository" "app" {
  name = var.ecr_repo_name
  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "AES256"
  }
}

# EKS cluster using terraform-aws-modules/eks
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.0.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  
# cluster_create_timeout is not a valid argument for this module.
# Remove any line like: cluster_create_timeout = ...
  eks_managed_node_groups = {
    default = {
      desired_capacity = var.node_count
      max_capacity     = var.node_max
      min_capacity     = var.node_min
      instance_types   = [var.node_type]
    }
  }

  tags = {
    Project = "eks-web-game"
  }
}

# Security Group for Jenkins
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-security-group"
  description = "Allow SSH and Jenkins HTTP access"
  vpc_id      = module.eks.vpc_id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "Allow Jenkins HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
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

resource "aws_instance" "jenkins_server" {
  ami                         = "ami-0c94855ba95c71c99"
  instance_type               = "t3.micro"
  key_name                    = "web-game-app-key"
  subnet_id                   = module.eks.private_subnets[0]
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    set -e

    yum update -y
    yum install -y wget curl git

    wget https://packages.adoptium.net/artifactory/rpm/amazonlinux/2/x86_64/Packages/t/temurin-21-jdk-21.0.2.13-1.x86_64.rpm
    yum localinstall -y temurin-21-jdk-21.0.2.13-1.x86_64.rpm

    echo "export JAVA_HOME=/usr/lib/jvm/temurin-21-jdk" >> /etc/profile
    echo "export PATH=\\$JAVA_HOME/bin:\\$PATH" >> /etc/profile
    source /etc/profile

    wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
    yum install jenkins -y

    yum install -y maven
    yum install -y docker
    systemctl start docker
    systemctl enable docker
    usermod -aG docker jenkins

    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    ./aws/install

    systemctl enable jenkins
    systemctl start jenkins

  EOF

  tags = {
    Name = "Jenkins-Server"
  }
}