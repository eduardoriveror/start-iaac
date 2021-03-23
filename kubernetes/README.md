# Creating a EKS Cluster with Jenkins and Terraform

## Prerequisites
- AWS Account and IAM user with programatic access and an IAM policy attached to it
- S3 bucket to store the remote state
- Networking infrastructure in place (VPC, Subnets, etc)
- Jenkins server in an AWS VPC
- Docker image with terragrunt and terraform

## Considerations
- When using the subnets available in the default VPC, for EKS Ingress to start a ALB, this should be tagged with the following tags:
    **kubernetes.io/cluster/start-cluster	shared**
    **kubernetes.io/role/elb	1**
- The remote backend is generated automatically via terragrunt. This is because terraform by itself does not allow you to template sensitive data like the name of the bucket.

## What it installs:
- An EKS cluster, with one worker group (Several can be created with a tweak of the values provided to the terraform module)
- Tekton CRDs and tekton dashboards
- ArgoCD
- AWS Ingress controller