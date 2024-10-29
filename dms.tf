# Database Migration Service requires the below IAM Roles to be created before
# replication instances can be created. See the DMS Documentation for
# additional information: https://docs.aws.amazon.com/dms/latest/userguide/security-iam.html#CHAP_Security.APIRole
#  * dms-vpc-role
#  * dms-cloudwatch-logs-role
#  * dms-access-for-endpoint

data "aws_iam_policy_document" "dms_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["dms.amazonaws.com"]
      type        = "Service"
    }
  }
}

# Using for_each

locals {
  dms_policies = [
    "arn:aws:iam::aws:policy/service-role/AmazonDMSRedshiftS3Role",
    "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole",
    "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
  ]
}

resource "aws_iam_role" "dms-access-for-endpoint" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-access-for-endpoint"
}

resource "aws_iam_role_policy_attachment" "dms-access-for-endpoint-AmazonDMSRedshiftS3Role" {
  for_each   = toset(local.dms_policies)
  policy_arn = each.value
  role       = aws_iam_role.dms-access-for-endpoint.name
}

# Create a new replication instance
resource "aws_dms_replication_instance" "test" {
  allocated_storage          = 20
  apply_immediately          = true
  auto_minor_version_upgrade = true
  availability_zone          = "us-west-2b"
  engine_version             = "3.5.1"
  #kms_key_arn                  = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  multi_az = false
  #preferred_maintenance_window = "sun:10:30-sun:14:30"
  publicly_accessible         = true
  replication_instance_class  = "dms.t2.micro"
  replication_instance_id     = "dms-replication-instance"
  replication_subnet_group_id = aws_dms_replication_subnet_group.dms-subnet.id

  tags = {
    Name = "DMS-Replication-Instance"
  }

  vpc_security_group_ids = [
    aws_security_group.data_migration.id
  ]

  depends_on = [
    aws_iam_role_policy_attachment.dms-access-for-endpoint-AmazonDMSRedshiftS3Role,
  ]
}

### Create the dms-vpc-role IAM Role:
resource "aws_iam_role" "dms-vpc-role" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-vpc-role"
}

resource "aws_iam_role_policy_attachment" "dms-vpc-role-attachment" {
  role       = aws_iam_role.dms-vpc-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
}
###

# Create a new replication subnet group
resource "aws_dms_replication_subnet_group" "dms-subnet" {
  replication_subnet_group_description = "Example replication subnet group"
  replication_subnet_group_id          = "dms-replication-subnet-group"

  subnet_ids = [
    aws_subnet.subnet_az1.id,
    aws_subnet.subnet_az2.id
  ]

  tags = {
    Name = "dms-subnet-group"
  }
}

# Create a new endpoint
resource "aws_dms_endpoint" "source" {
  database_name               = "ORCL"
  endpoint_id                 = "sourcedb"
  endpoint_type               = "source"
  engine_name                 = "oracle"
  extra_connection_attributes = ""
  password                    = "admin123"
  port                        = 1521
  server_name                 = "sourcedb"
  ssl_mode                    = "none"

  tags = {
    Name = "source-endpoint"
  }

  username = "admin"
}

resource "aws_dms_endpoint" "target" {
  database_name               = "AURORA"
  endpoint_id                 = "targetdb"
  endpoint_type               = "target"
  engine_name                 = "aurora"
  extra_connection_attributes = ""
  password                    = "admin1234"
  port                        = 3306
  server_name                 = "targetdb"
  ssl_mode                    = "none"

  tags = {
    Name = "target-endpoint"
  }

  username = "admin"
}

# Create a new replication task
resource "aws_dms_replication_task" "test" {
  migration_type           = "full-load"
  replication_instance_arn = aws_dms_replication_instance.test.replication_instance_arn
  replication_task_id      = "dms-replication-task"
  source_endpoint_arn      = aws_dms_endpoint.source.endpoint_arn
  table_mappings           = "{\"rules\":[{\"rule-type\":\"selection\",\"rule-id\":\"1\",\"rule-name\":\"1\",\"object-locator\":{\"schema-name\":\"%\",\"table-name\":\"%\"},\"rule-action\":\"include\"}]}"

  tags = {
    Name = "DMS-task"
  }

  target_endpoint_arn = aws_dms_endpoint.target.endpoint_arn
}
