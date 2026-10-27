# Multi-Environment AWS Infrastructure with Terraform and Jenkins

Terraform modules provision a small AWS network and EC2 instance for three named environments (`dev`, `test`, and `prod`). A Jenkins declarative pipeline selects an environment and an action (`apply` or `destroy`), runs Terraform, and pauses for human confirmation before changing infrastructure.

## Project overview

- **Infrastructure as code:** Terraform provisions a VPC, public subnet, internet gateway, default internet route, security group, and one EC2 instance.
- **Environment configuration:** Terraform workspaces select separate CIDR ranges and configuration for `dev`, `test`, and `prod`.
- **Remote state:** Terraform is configured to store state in an S3 backend, with S3 lock files enabled.
- **Deployment automation:** Jenkins checks out the repository, checks Terraform formatting, initializes the backend, selects or creates the requested workspace, and generates a plan for apply runs.
- **Approval and visibility:** Jenkins requires a manual confirmation before apply or destroy, archives the text plan for apply runs, and sends success/failure email notifications.
- **Outputs:** Terraform reports the selected workspace, VPC ID, and EC2 public IP.

## Architecture

```text
GitHub repository
       |
       v
Jenkins pipeline (ENVIRONMENT + ACTION parameters)
       |
       +--> Terraform format check
       +--> Initialize S3 backend and select/create workspace
       +--> Plan and archive plan.txt (apply only)
       +--> Manual confirmation
       |
       +--> Apply or destroy in the selected workspace
                    |
                    v
          AWS resources in us-east-1
          VPC -> public subnet -> EC2 instance
```

The current configuration places the subnet in `us-east-1a`. The three workspaces use distinct VPC/subnet CIDRs (`10.1.0.0/16` / `10.1.1.0/24`, `10.2.0.0/16` / `10.2.1.0/24`, and `10.3.0.0/16` / `10.3.1.0/24`) and currently use the same `t3.micro` instance type.

## Repository layout

```text
.
├── jenkinsfiles                  # Jenkins declarative pipeline
├── README.md
└── terraform/
    ├── backend.tf                # Terraform/provider versions, S3 backend, AWS provider
    ├── main.tf                   # Root module and workspace-based configuration
    ├── outputs.tf                # Environment, VPC ID, EC2 public IP
    ├── variables.tf              # Region and dev/test/prod configuration
    └── modules/
        └── vpc_ec2/              # VPC, subnet, routing, security group, EC2
```

## Prerequisites

- An AWS account and credentials available to Terraform/Jenkins.
- Terraform **1.15.7 or later** (as required by `terraform/backend.tf`).
- An S3 bucket in `us-east-1` for the Terraform backend. The current backend bucket is `terrafrom-bucket-project`; change the bucket name in `terraform/backend.tf` to one you own before initializing if it is unavailable. The bucket must exist before `terraform init`.
- Jenkins with a Linux agent that has Terraform installed and can run shell steps.
- Jenkins plugins/configuration used by the pipeline: Pipeline, Git, Workspace Cleanup (`cleanWs`), AWS Credentials (`AmazonWebServicesCredentialsBinding`), and Email Extension (`emailext`).

## Jenkins setup

1. Add an AWS credential of type **AWS Credentials** with the ID `aws cread`. This exact ID is referenced by the pipeline. Store credentials in Jenkins; do not put access keys in the repository.
2. Add Git credentials with the ID `terra-jenkins` if required to access the repository.
3. Create a Jenkins **Pipeline** job. Set **Definition** to **Pipeline script from SCM**, select **Git**, and configure:
   - Repository: `https://github.com/ravirajpatil198/teraaform.git`
   - Branch: `*/main`
   - Script Path: `jenkinsfiles`
4. Ensure the Jenkins agent can access the configured S3 backend and AWS resources. Email notifications also require the Email Extension plugin to be configured for your Jenkins instance. The recipient address is hard-coded in `jenkinsfiles`; update it there if needed.
5. Run the job with parameters:
   - `ENVIRONMENT`: `dev`, `test`, or `prod`
   - `ACTION`: `apply` or `destroy`
6. Review the archived `terraform/plan.txt` for apply runs and approve or abort at the pipeline's manual confirmation gate.

The pipeline uses `terraform fmt -check` from the `terraform` directory. This checks the root Terraform files; it does not explicitly recurse into `modules/`.

## Run Terraform locally

From the repository root, configure AWS credentials using your normal AWS profile or environment setup, then:

```sh
cd terraform
terraform init
terraform workspace new dev
terraform plan
terraform apply
terraform output
```

To use another environment, select or create that workspace before planning:

```sh
terraform workspace select test || terraform workspace new test
terraform plan
terraform apply
```

To remove resources, first select the workspace to destroy, inspect the plan, then run:

```sh
terraform workspace select dev
terraform plan -destroy
terraform destroy
```

Do not delete the S3 state bucket as part of routine cleanup. Destroy each workspace's resources before removing or changing the backend.

## Important security and operational notes

- **SSH is open to the internet:** The security group allows inbound TCP port 22 from `0.0.0.0/0`. Restrict this to a trusted IP range before deploying, especially in a shared or production AWS account.
- **HTTP is open but no web server is installed:** Port 80 is allowed, but the Terraform configuration does not install or configure a web application or web server.
- **No SSH key is configured:** The EC2 resource does not set a key pair, so opening port 22 alone does not provide a configured SSH login method.
- **Single-AZ demonstration setup:** The subnet is pinned to `us-east-1a`, and each workspace creates one EC2 instance. This is not a highly available or production-hardened architecture.
- **Review the AMI:** The module refers to a fixed AMI ID rather than selecting a current image dynamically. Verify that it is valid for `us-east-1` before deployment.
- **S3 backend prerequisite:** The backend bucket name is hard-coded. Use a bucket you control and consider enabling S3 versioning and restricting bucket access. Backend resources are not created by this Terraform configuration.
- **Costs:** `t3.micro` is not guaranteed to be free. AWS charges may apply for EC2, storage, and other resources. Destroy resources when finished and verify the AWS account afterward.
- **Production workspace naming is not production readiness:** `prod` currently uses the same instance size and single-subnet design as the other environments.

## Resume-ready project summary

**Terraform and Jenkins Multi-Environment AWS Infrastructure** — Built reusable Terraform configuration and a Jenkins pipeline to provision and destroy AWS VPC/EC2 environments for dev, test, and prod. Implemented workspace-based environment configuration, S3 remote state with lock files, parameterized deployment actions, manual approval gates, archived Terraform plans, and pipeline email notifications.

## Verification

Check formatting locally, including the module:

```sh
cd terraform
terraform fmt -check -recursive
```

The Jenkins pipeline currently runs the non-recursive `terraform fmt -check` command described above; the recursive command is a broader local check.
