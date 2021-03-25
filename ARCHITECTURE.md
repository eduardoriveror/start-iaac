## Tools

- *Jenkins:* CI/CD engine used to deploy the underlying infrastructure in an automated way
- *Terraform:* Infrastructure as a Code tool used to write the resources that after will become the underlying infrastructure
- *AWS:* Cloud provider, among the services used we can list
    - EKS with an EC2 node group (More worker groups can be created editing terraform's main file)
    - Autoscaling group
    - Cloudwatch Logs
    - IAM Roles and users
    - VPC
    - S3 (To keep safely terraform's remote state)
    - Route53
- Tekton and ArgoCD: Tekton allows the user to develop a group of steps that can grouped in tasks. Moreover, tasks can be grouped in pipelines, that will execute the tasks in an sequencial manner with a pipeline run. The advantage of this is that empowers the developers, and allows them to create simple procedures to test, build and deploy its product using gitops principles and a tool that is designed to work in kubernetes. (Each task runs in a container). ArgoCD listen to remote or local repositories set in an application object. So automatically or manually can synchronize new updates and deploy/delete objects in a kubernetes cluster.

## Repositories:
- _https://github.com/eduardoriveror/start.git:_ Where the java application is. There are two folders named argocd and tekton. The argocd folder hosts the yaml manifests of the kubernetes objects needed for the application to run: A namespace, a deployment and a service. (Kustomize or helm charts could also be used)
- _https://github.com/eduardoriveror/start-iaac.git:_ Where the infrastructure tools code are. There are two folders called Jenkins and Kubernetes where the terraform code used to deploy Jenkins in an EC2 instance and an EKS cluster with an EC2 worker group is. A third folder called argo contains the manifests of the application objects. So this manifests state which repository needs to be synced.

## How it works
- Creating a Jenkins instance (OPTIONAL)
- The Jenkinsfile in this repository list the steps to deploy a kubernetes cluster in AWS, and once this one is created, it also deploy ArgoCD and Tekton in separate namespaces. 
- After this, applications objects (ArgoCD CRD depoyed during the installation process) are created, these target the code repository to the mentioned folders to deploy what is needed to deploy the application, and also the resources needed to create the pipeline that will build a docker container and push it to a docker repository (Dockerhub in this case)