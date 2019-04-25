resource "aws_alb" "default" {
  name            = "${var.context.product.name}-${var.context.environment.name}"
  internal        = false
  security_groups = [var.aws_security_group_alb_id]
  subnets         = var.subnets
  idle_timeout    = 4000

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_alb_target_group" "default" {
  name     = "default-${var.context.environment.name}"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  tags = {
    Name        = "default-${var.context.environment.name}"
    Product     = var.context.product.name
    Environment = var.context.environment.name
  }
}

resource "aws_alb_listener" "default" {
  load_balancer_arn = aws_alb.default.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.default.arn
    type             = "forward"
  }
}

