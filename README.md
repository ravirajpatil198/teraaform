# Multi-Environment Terraform Jenkins CI/CD Pipeline
##  Architecture Diagram
terraform-jenkins-project/
├── .gitignore
├── Jenkinsfile
├── README.md
└── terraform/
    ├── backend.tf
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── modules/
        └── vpc_ec2/
            ├── main.tf
            ├── variables.tf
            └── outputs.tf


# Setup Instructions
1. Configure AWS Credentials in Jenkins
To allow Jenkins to communicate securely with your AWS account, register your security tokens:
Navigate to the Jenkins Home Dashboard and selectd Manage Jenkins ➔ Credentials.
Click the (global) domain scope link, then select Add Credentials.
Select AWS Credentials from the Kind dropdown menu selection.
Input the ID exactly as: aws cread
Paste your active AWS Access Key ID and AWS Secret Access Key into their corresponding fields, then click Create.

2. Connect the Jenkins Pipeline to GitHub
From the main Jenkins menu, click New Item, name it terraform jenkins project choose Pipeline, and click OK.
Scroll to the Pipeline configuration section.
Switch the Definition dropdown menu option to Pipeline script from SCM.
Set the SCM configuration field to Git.
Paste your repository URL: https://github.com/ravirajpatil198/teraaform.git
Specify the tracking branch configuration line exactly as: */main
Ensure the Script Path points precisely to jenkinsfiles, then click Save.


# Deployment & Operational Steps

Step 1: Registering Pipeline Parameters
Click the Build Now button on the left sidebar menu once.
Note: This first run will fetch your repository code, scan your parameters block structure, and stop. Click the red cancel button to abort this initial run cleanly.
Refresh your web browser page. The static "Build Now" link will have updated to a dynamic Build with Parameters workflow interface.

Step 2: Triggering an Infrastructure Run
Click Build with Parameters to reveal your selection options panel:
ENVIRONMENT: Select your target workspace track (dev, test, or prod).
ACTION: Set your operational execution step to apply.
Click the green Build button to initiate the automated stage tracking lanes.

Step 3: Verification & Manual Approval Gate
The automation engine will securely check out your code, apply terraform fmt styles, select or create your specified environment workspace, and construct your deployment blueprint.
Once the Terraform Plan stage shows green success, click on the current run's Build Artifacts menu link at the top to review your generated layout configurations inside plan.txt.
The execution phase will pick up the workflow and provision your free-tier eligible t3.micro instances securely within the stable us-east-1a zone.

Step 4: Deconstructing Resources 
To clear your AWS footprint completely once you finish evaluating your environments and avoid incurring costs:
Open your Jenkins job menu dashboard and select Build with Parameters.
Choose your active targeted environment from the ENVIRONMENT dropdown field (e.g., prod).
Change your structural execution ACTION option from apply to destroy.

Click Build, pass the interactive Manual Gate confirmation step, and Terraform will cleanly clear out all associated instances, networks, and configurations.
