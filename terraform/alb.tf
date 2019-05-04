resource "aws_security_group" "alb" {
  name        = "${var.app_name}-${var.environment}-alb"
  description = "ALB SG for ${var.app_name} in ${var.environment}"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = "${var.app_port}"
    to_port     = "${var.app_port}"
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

module "alb" {
  source                   = "github.com/terraform-aws-modules/terraform-aws-alb"
  logging_enabled          = false
  load_balancer_name       = "${var.app_name}-${var.environment}-alb"
  security_groups          = ["${aws_security_group.alb.id}"]
  subnets                  = "${module.vpc.public_subnets}"
  tags                     = "${map("Environment", var.environment)}"
  vpc_id                   = "${module.vpc.vpc_id}"
  http_tcp_listeners       = "${list(map("port", var.app_port, "protocol", "HTTP"))}"
  http_tcp_listeners_count = "1"
  target_groups            = "${list(map("name", "${var.app_name}-${var.environment}-tg", "backend_protocol", "HTTP", "backend_port", var.app_port))}"
  target_groups_count      = "1"
}

resource "aws_lb_target_group_attachment" "tga" {
  target_group_arn = "${element(module.alb.target_group_arns, 0)}"
  target_id        = "${element(module.ec2.id, 0)}"
  port             = "${var.app_port}"
}
