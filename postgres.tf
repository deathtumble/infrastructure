resource "aws_db_subnet_group" "default" {
   name = "main"
   subnet_ids = ["${aws_subnet.av1.id}", "${aws_subnet.av2.id}"] 
}

resource "aws_security_group" "postgres" {
  name = "postgres"

  description = "dashing security group"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_cidr}", "${var.vpc_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "postgres-${var.product}-${var.environment}"
    Product     = "${var.product}"
    Environment = "${var.environment}"
  }
}


resource "aws_db_instance" "concourse" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "9.6.6"
  instance_class       = "db.t2.micro"
  name                 = "concourse"
  username             = "concourse"
  db_subnet_group_name = "${aws_db_subnet_group.default.name}"
  password             = "${var.concourse_postgres_password}"
  parameter_group_name = "default.postgres9.6"
  vpc_security_group_ids = ["${aws_security_group.postgres.id}"]
  skip_final_snapshot = true
}

