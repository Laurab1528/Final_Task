resource "aws_instance" "runner" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  associate_public_ip_address = false

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y curl jq
              cd /home/ubuntu
              mkdir actions-runner && cd actions-runner
              curl -o actions-runner-linux-x64-2.325.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.325.0/actions-runner-linux-x64-2.325.0.tar.gz
              tar xzf ./actions-runner-linux-x64-2.325.0.tar.gz
              TOKEN=$(curl -s -X POST -H "Authorization: token ${var.github_pat}" https://api.github.com/repos/Laurab1528/Final_Task/actions/runners/registration-token | jq -r .token)
              ./config.sh --url https://github.com/Laurab1528/Final_Task --token $TOKEN --unattended
              ./run.sh &
              EOF

  tags = {
    Name = "github-runner"
  }
} 