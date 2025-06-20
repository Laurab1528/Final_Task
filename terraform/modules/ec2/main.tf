data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "runner" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.runner_instance_type
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker
              sudo service docker start
              sudo usermod -a -G docker ec2-user
              
              # Install git
              sudo yum install -y git

              # Install GitHub Actions Runner
              mkdir /home/ec2-user/actions-runner && cd /home/ec2-user/actions-runner
              curl -o actions-runner-linux-x64-2.303.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.303.0/actions-runner-linux-x64-2.303.0.tar.gz
              tar xzf ./actions-runner-linux-x64-2.303.0.tar.gz
              chown -R ec2-user:ec2-user /home/ec2-user/actions-runner
              
              # Configure as self-hosted runner
              sudo -u ec2-user ./config.sh --url https://github.com/laurapcamachog/final_second_course --token ${var.github_pat} --unattended
              
              # Install and run as a service
              sudo ./svc.sh install
              sudo ./svc.sh start
              EOF

  tags = {
    Name = "GitHub-Actions-Runner"
  }
} 