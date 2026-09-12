resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-oracle"
  subnet_ids = var.database_subnet_ids
  tags       = merge(var.tags, { Name = "${var.name}-oracle" })
}

resource "aws_security_group" "oracle" {
  name        = "${var.name}-oracle"
  description = "Oracle access from EKS workloads"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Oracle JDBC from EKS"
    protocol        = "tcp"
    from_port       = 1521
    to_port         = 1521
    security_groups = [var.allowed_security_group_id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = var.tags
}

resource "aws_db_instance" "oracle" {
  identifier                  = "${var.name}-oracle"
  engine                      = "oracle-se2"
  license_model               = "license-included"
  instance_class              = var.instance_class
  allocated_storage           = var.allocated_storage
  max_allocated_storage       = var.allocated_storage * 3
  storage_type                = "gp3"
  storage_encrypted           = true
  username                    = "histadmin"
  manage_master_user_password = true
  port                        = 1521
  db_name                     = "HISTDB"
  db_subnet_group_name        = aws_db_subnet_group.this.name
  vpc_security_group_ids      = [aws_security_group.oracle.id]
  publicly_accessible         = false
  multi_az                    = var.multi_az
  backup_retention_period     = 7
  maintenance_window          = "sun:03:00-sun:04:00"
  backup_window               = "01:00-02:00"
  auto_minor_version_upgrade  = true
  deletion_protection         = var.deletion_protection
  skip_final_snapshot         = !var.deletion_protection
  final_snapshot_identifier   = var.deletion_protection ? "${var.name}-oracle-final" : null
  copy_tags_to_snapshot       = true
  apply_immediately           = false
  tags                        = var.tags
}

# Terraform creates the secret container but intentionally does not create a
# secret value, keeping the Oracle application password out of state.
resource "aws_secretsmanager_secret" "application" {
  name                    = "${var.name}/oracle/application"
  description             = "Dedicated HistData Oracle schema credentials"
  recovery_window_in_days = 7
  tags                    = var.tags
}
