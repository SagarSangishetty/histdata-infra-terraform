# HistData AWS infrastructure

Terraform for the HistData lab. This is intentionally a separate repository
from the application and Kubernetes configuration.

## Provisions

- Multi-AZ VPC with public/private/database subnets
- Internet gateway and one NAT gateway for the dev lab
- EKS control plane and managed node group in private subnets
- ECR application repository
- Private, encrypted S3 historical-data bucket
- Private Oracle SE2 RDS instance with an RDS-managed master secret
- EKS OIDC provider and application IRSA role scoped to the data bucket
- Optional ACM certificate and Route 53 record prerequisites
- Optional AWS DataSync NFS-to-S3 location/task once real agent inputs are known

## Important cost warning

EKS, NAT Gateway, RDS Oracle, ALB, and DataSync are billable. Use a dedicated
lab account, create an AWS Budget first, and destroy resources after practice.

## State bootstrap

Create the backend once:

```bash
cd bootstrap/state-backend
terraform init
terraform apply -var='state_bucket_name=<globally-unique-name>'
```

Copy the output values into `environments/dev/backend.hcl`, then initialize:

```bash
cd environments/dev
cp backend.hcl.example backend.hcl
cp dev.auto.tfvars.example dev.auto.tfvars
terraform init -backend-config=backend.hcl
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

Never commit `backend.hcl`, `.auto.tfvars`, state, plans, or credentials.

## DataSync

DataSync is disabled by default. Enable it only after an agent is installed and
activated near the on-prem NFS data directory. Supply the agent ARN, reachable
NFS hostname, and export path. The task maps that source to the S3 bucket.

## Oracle

RDS manages the master password in Secrets Manager. Terraform also creates an
empty application-secret container without putting a password in state. Create
the least-privileged `HISTDATA` schema user, then populate that secret manually:

```bash
aws secretsmanager put-secret-value \
  --secret-id <oracle_application_secret_arn> \
  --secret-string '{"username":"HISTDATA","password":"replace-securely"}'
```

Do not run the application as the RDS master user or commit the JSON value.

## Destruction

The S3 bucket is protected against accidental deletion while it contains data.
Empty the lab bucket deliberately, then run:

```bash
terraform destroy
```
