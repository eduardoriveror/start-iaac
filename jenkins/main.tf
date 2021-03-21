
provider "aws" {
  region  = var.region
}

data "aws_route53_zone" "selected" {
  name         = "${var.hosted_zone}."
  private_zone = false
}

variable "ingressrules" {
  type    = list(number)
  default = [80, 443, 22]
}

resource "aws_security_group" "my_traffic" {
  name        = "Allow my traffic"
  description = "Allow ssh and standard http/https ports inbound and everything outbound"

  dynamic "ingress" {
    iterator = port
    for_each = var.ingressrules
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "TCP"
      cidr_blocks = ["${var.my_ip}"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Terraform" = "true"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

    owners = ["099720109477"] #Canonical
}

resource "aws_key_pair" "jenkins" {
  key_name   = "jenkins-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDEhd0XdD+VsSDhfqliIKEJqX93hZqIA/H+UiFDGGnLLHD9/TcPZRlt1oODGE2nFBoPMu77TThjxurIJfQrfIUZqWIIsil8W2Gi5sOlfyZ4HNLW/7EZZ8qbE589PuXk2dHq2Ak+m1PvG1Fp/7hixKD66YywQtQpCRzRTuvuPHAoMJOIyLfSdcaFO6rVQcHcGQMgA9aiU3axTkKpAmjxQIW9Zlwq5A2YwlZCVY9Q82wVKznDJOg+MIegAzd/JOQ/h3Tsg6OoX3NqhFdvH8xVeWq4wQ2JpTPchCWojOB98sMLcSst9TYZS39jEPsNw0FCk2MSEbtgTUsQWdLv72rSH8f2v2shbMeTeIJmbOPsKQfWwFtI5hRCF6MNy+lFD2f1K/xOshWRomYhFMiluFJQubg8i0L3mfrxa1hWjaj0mznEDv0HsXqEFVzoGY+tv+Q9+HfzPucC23c3Mld7hrUovzZiskNuub3054N39YULf8uh+ScAmPE6yENdW6oG2t91WgE= erivero@Eduardos-MacBook-Pro.local"
}

resource "aws_instance" "jenkins" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.my_traffic.name]
  key_name        = aws_key_pair.jenkins.key_name

  provisioner "remote-exec" {
    inline = [
      "wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -",
      "sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'",
      "sudo apt update",
      "sudo apt install -y default-jre",
      "sudo apt install -y jenkins",
      "sudo systemctl start jenkins",
      "sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080",
      "sudo sh -c \"iptables-save > /etc/iptables.rules\"",
      "echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections",
      "echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections",
      "sudo apt-get -y install iptables-persistent",
      "sudo ufw allow 8080",
      "sudo apt install apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable\"",
      "sudo apt update",
      "sudo apt install -y docker-ce",
      "sudo gpasswd -a $USER docker",
    ]
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("../jenkins-key")
  }

  tags = {
    "Name"      = "Jenkins_Server"
    "Terraform" = "true"
  }
}

resource "aws_eip" "jenkins" {
  instance = aws_instance.jenkins.id
  vpc      = true
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "jenkins.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_eip.jenkins.public_ip}"]
}



