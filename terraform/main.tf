resource "aws_instance" "jenkins_server" {
  ami                    = "ami-0c94855ba95c71c99"  # Amazon Linux 2 AMI in us-east-1
  instance_type          = "t3.micro"
  private_ip             = "172.31.32.10" # Match your subnet CIDR
  key_name               = "web-game-app-key"
  subnet_id              = "subnet-053ad24e3818e1607"
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    set -e

    # Update packages
    yum update -y

    # Install dependencies
    yum install -y wget curl git

    # Install Temurin JDK 21
    wget https://packages.adoptium.net/artifactory/rpm/amazonlinux/2/x86_64/Packages/t/temurin-21-jdk-21.0.2.13-1.x86_64.rpm
    yum localinstall -y temurin-21-jdk-21.0.2.13-1.x86_64.rpm

    # Set JAVA_HOME
    echo "export JAVA_HOME=/usr/lib/jvm/temurin-21-jdk" >> /etc/profile
    echo "export PATH=\\$JAVA_HOME/bin:\\$PATH" >> /etc/profile
    source /etc/profile

    # Install Jenkins
    wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
    yum install jenkins -y

    # Start & Enable Jenkins
    systemctl enable jenkins
    systemctl start jenkins
  EOF

  tags = {
    Name = "Jenkins-Server"
  }
}
