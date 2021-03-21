# Start-iaac

This is a repository that allows you to create an EKS cluster using Jenkins in an EC2 instance as a CI/CD engine.

The jenkins folder itself is meant to be used as a pre-step to start a Jenkins instance if needed, while the kubernetes folder is the one that is going to be used by Jenkins to create a cluster.

## Prerequisites:

### For Jenkins:
- A hosted zone in route 53
- An S3 bucket to store the remote state

### For EKS
- AWS Account and IAM user with programatic access and an IAM policy attached to it
- S3 bucket to store the remote state
- Networking infrastructure in place (VPC, Subnets, etc)
- Jenkins server in an AWS VPC
- Docker image with terragrunt and terraform

## Procedure

### For Jenkins:
- Setting up credentials AWS CLI credentials in your local environment (Programatic access key of a IAM user with an IAM policy attached to its group or an IAM role that it can assume)
- Creating an SSH key pair in the root folder called jenkins-key with the following command
```
ssh-keygen -f jenkins-key
```
- In the Jenkins folder, renaming _file.tfvars.example_ to _terraform.tfvars_, filling the required variables and issue the command 
```
terragrunt apply
``` 