# Oracle to Aurora Database Migration Using Terraform

This repository provides a Terraform configuration to deploy resources necessary for migrating an Oracle database to Amazon Aurora, utilizing AWS Database Migration Service (DMS). The setup includes security groups, VPCs, database instances, replication tasks, and DMS endpoints.

## Project Structure
The repository includes the following Terraform files:

- **db.tf**: Defines Oracle and Aurora RDS instances, along with subnet groups.
- **dms.tf**: Configures AWS DMS, including IAM roles, replication instances, endpoints, and replication tasks.
- **inputs.tf**: Specifies input variables for database credentials.
- **provider.tf**: Sets up the AWS provider.
- **sg.tf**: Configures VPCs, security groups, and associated rules.
- **Makefile**: Provides commands for validation, planning, testing, application, and teardown of Terraform configurations.

## Prerequisites
- Terraform
- AWS CLI configured with appropriate permissions
- IAM Roles for DMS:
    - dms-vpc-role
    - dms-cloudwatch-logs-role
    - dms-access-for-endpoint
Refer to the [AWS DMS IAM Documentation](https://docs.aws.amazon.com/dms/latest/userguide/security-iam.html#CHAP_Security.APIRole) for more details.

## Configuration Details
### Database Instance (db.tf)
Defines the Oracle source database and the Aurora target database:

- **Source (Oracle)**: Oracle Enterprise Edition with public accessibility.
- **Target (Aurora)**: Aurora MySQL cluster in a Multi-AZ setup.

### DMS (dms.tf)
Configures DMS resources for data migration:

- **Replication Instanc**e: Provides compute power for data replication.
- **Endpoints**: Connects DMS to both the Oracle source and Aurora target.
- **Replication Task**: Configures a full-load migration task from source to target.

### Network and Security (sg.tf)
Defines VPC and security groups:

- **VPC**: Creates a virtual network for migration resources.
- **Security Groups**: Allows secure access for Oracle and MySQL ports within the VPC.

## Makefile Targets
The Makefile includes targets for automating Terraform tasks:

- **check**: Initializes, formats, and validates the Terraform configuration.
- **plan**: Generates an execution plan for review.
- **test**: Runs tfsec for security checks.
- **apply**: Deploys resources based on the Terraform configuration.
- **destroy**: Destroys resources created by Terraform.

## Usage Instructions
1. **Clone the repository** and navigate to the project directory.
2. **Configure environment variables** or modify inputs.tf for database credentials.
3. **Run Makefile commands**:
    - `make check`: Validates the configuration.
    - `make plan`: Previews the deployment plan.
    - `make apply`: Deploys resources to AWS.
4. **Verify AWS resources** to ensure successful setup.
5. **Clean up**: Run make destroy after migration is complete to delete all resources.
For more information, refer to the [AWS DMS Documentation](https://docs.aws.amazon.com/dms/latest/userguide/Welcome.html).
