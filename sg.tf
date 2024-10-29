resource "aws_vpc" "main" {
  cidr_block                       = "10.0.0.0/16"
  assign_generated_ipv6_cidr_block = true
  enable_dns_hostnames             = true
  enable_dns_support               = true

  tags = {
    Name = "Data-migration"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_security_group" "data_migration" {
  name        = "oracle-aurora-migration"
  description = "Migration of oracle to aurora"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "oracle-aurora-migration"
  }
}

resource "aws_security_group_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.data_migration.id
  cidr_blocks       = [aws_vpc.main.cidr_block]
  ipv6_cidr_blocks  = [aws_vpc.main.ipv6_cidr_block]
  from_port         = 1521
  type              = "ingress"
  protocol          = "tcp"
  to_port           = 1521
}


resource "aws_security_group_rule" "tls_ipv6" {
  security_group_id = aws_security_group.data_migration.id
  cidr_blocks       = [aws_vpc.main.cidr_block]
  ipv6_cidr_blocks  = [aws_vpc.main.ipv6_cidr_block]
  from_port         = 3306
  protocol          = "tcp"
  to_port           = 3306
  type              = "ingress"
}

resource "aws_security_group_rule" "self" {
  security_group_id        = aws_security_group.data_migration.id
  from_port                = 1
  to_port                  = 65535
  protocol                 = "-1"
  type                     = "ingress"
  source_security_group_id = aws_security_group.data_migration.id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.data_migration.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.data_migration.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}