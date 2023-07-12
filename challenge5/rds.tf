# module "rvips" {
#   source  = "#ModuleSource"
#   version = "~> 3.0"
# } 

resource "aws_db_instance" "bensrds" {
  identifier             = "bensrds"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "mysql"
  engine_version         = "5.7"
  name                   = "foo"
  ##Wrongwaytodothis!todo:Correct username/pw here
  username               = var.user_name
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.benrds.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  #  parameter_group_name   = aws_db_parameter_group.education.name
  publicly_accessible = true
  skip_final_snapshot = true
}

resource "aws_db_subnet_group" "benrds" {
  name       = "main"
  #todo:lookup sg, no hardcode
  subnet_ids = ["subnet-081a2f71a1b9b5872", "subnet-09469596201c85ffb"]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_security_group" "rds_sg" {
  name   = "rds-sg"
  vpc_id = "vpc-06d3f8ac2206caa8b"


  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "TCP"
    cidr_blocks = module.rvips.rv_ips
  }
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "TCP"
    cidr_blocks = ["100.67.16.0/22"]
  }
}
