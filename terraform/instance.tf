resource "aws_security_group" "instance" {
  name        = "${var.app_name}-${var.environment}-instance-sg"
  description = "Instance SG for ${var.app_name} in ${var.environment}"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = "${var.app_port}"
    to_port     = "${var.app_port}"
    protocol    = "tcp"
    cidr_blocks = ["${local.public_subnet_cidrs}"]
  }

  ingress {
    from_port   = "${var.ssh_port}"
    to_port     = "${var.ssh_port}"
    protocol    = "tcp"
    cidr_blocks = ["${var.allowed_ssh_ips}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.allowed_ssh_ips}"]
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/templates/cloud-config.tpl")}"

  vars = {
    authorized_key = "${file("keys/${var.app_name}.pub")}"
    app_port       = "${var.app_port}"
  }
}

data "aws_ami" "ubuntu_ami" {
  most_recent = true             #20190212.1
  owners      = ["099720109477"] #Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "${var.app_name}-key"
  public_key = "${file("keys/${var.app_name}.pub")}"
}

data "aws_subnet_ids" "all" {
  vpc_id = "${module.vpc.vpc_id}"
}

module "ec2" {
  source = "github.com/terraform-aws-modules/terraform-aws-ec2-instance"

  instance_count = 1

  name                        = "${var.app_name}-${var.environment}-instance"
  key_name                    = "${aws_key_pair.ssh_key.key_name}"
  user_data                   = "${data.template_file.user_data.rendered}"
  ami                         = "${data.aws_ami.ubuntu_ami.id}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${element(data.aws_subnet_ids.all.ids, 0)}"
  vpc_security_group_ids      = ["${aws_security_group.instance.id}"]
  associate_public_ip_address = true
}
