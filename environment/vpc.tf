module "vpc" {
  source                    = "../modules/vpc"
  vpc_name                  = "primary"
  context                   = var.context
  aws_security_group_alb_id = aws_security_group.alb.id
}

resource "aws_efs_mount_target" "az1" {
  file_system_id = var.context.region.efs_id
  subnet_id      = module.vpc.az1_subnet_id

  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "az2" {
  file_system_id = var.context.region.efs_id
  subnet_id      = module.vpc.az2_subnet_id

  security_groups = [aws_security_group.efs.id]
}

resource "aws_security_group" "efs" {
  name = "efs-${var.context.product.name}-${var.context.environment.name}"

  vpc_id = module.vpc.vpc_id

  ingress {
    from_port       = "2049"
    to_port         = "2049"
    security_groups = [aws_security_group.os.id]
    protocol        = "tcp"
  }
}

