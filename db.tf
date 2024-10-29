resource "aws_db_instance" "oracle" {
  engine                    = "oracle-ee"
  db_name                   = "ORCL"
  identifier                = "sourcedb"
  instance_class            = "db.t3.small"
  allocated_storage         = 20
  publicly_accessible       = true
  username                  = var.db-username
  password                  = var.db-password
  vpc_security_group_ids    = [aws_security_group.data_migration.id]
  skip_final_snapshot       = true
  db_subnet_group_name      = aws_db_subnet_group.database_subnet_group.name
  final_snapshot_identifier = "oracle-snap"

  tags = {
    Name = "source-db"
  }
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count                = 2
  identifier           = "targetdb-${count.index}"
  cluster_identifier   = aws_rds_cluster.default.id
  instance_class       = "db.t3.medium"
  engine               = aws_rds_cluster.default.engine
  engine_version       = aws_rds_cluster.default.engine_version_actual
  publicly_accessible  = true
  db_subnet_group_name = aws_db_subnet_group.database_subnet_group.name
}

resource "aws_rds_cluster" "default" {
  cluster_identifier        = "targetdb"
  availability_zones        = ["us-west-2a", "us-west-2b"]
  engine                    = "aurora-mysql"
  database_name             = "AURORA"
  master_username           = "admin"
  master_password           = "admin1234"
  vpc_security_group_ids    = [aws_security_group.data_migration.id]
  db_subnet_group_name      = aws_db_subnet_group.database_subnet_group.name
  final_snapshot_identifier = "targetdb-snap"
  skip_final_snapshot       = true

}

data "aws_availability_zones" "available_zones" {}
output "azs" {
  value = data.aws_availability_zones.available_zones.names
}
# create a default subnet in the first az if one does not exit
resource "aws_subnet" "subnet_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available_zones.names[0]
}

# create a default subnet in the second az if one does not exit
resource "aws_subnet" "subnet_az2" {
  cidr_block        = "10.0.32.0/24"
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available_zones.names[1]
}


resource "aws_db_subnet_group" "database_subnet_group" {
  name        = "terraform-subnet"
  subnet_ids  = [aws_subnet.subnet_az1.id, aws_subnet.subnet_az2.id]
  description = "terraform-subnet-az1-az2"
  tags = {
    Name = "terraform-subnet"
  }
}
