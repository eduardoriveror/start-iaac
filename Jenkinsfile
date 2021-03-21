pipeline {
    parameters {
        choice(name: "debug_mode", choices: ["off","on"], description: "Enable Debug mode for terraform?")
        choice(name: "action", choices: ["apply","destroy"], description: "Which action will this playbook take")   
    }

    environment {
        TF_IN_AUTOMATION = "true"
        AWS_ID = credentials("terraform-userpass")
        VAR_FILE = credentials("terraform.tfvars")
    }
    agent {
        docker {
            label "docker"
            image "eduardoriveror/terragrunt-aws:v1.0 "
            alwaysPull true
            args  "--entrypoint='' -u root:sudo"
        }
    }
    stages {
        stage("Confirm Init") {
            steps {
                script { tf_log_level = "${params.debug_mode}" == 'on' ? 'INFO' : "" }
                timeout(time: 30, unit: "SECONDS") { input "You're provisioning an EKS cluster in AWS" }
            }
        }
        stage("Terragrunt Init") {
            steps {
                withAWS(credentials: "terraform-userpass", region: "eu-west-1") {
                    dir("${params.environment}") {
                        sh "aws --profile eks configure set aws_access_key_id ${env.AWS_ID_USR}"
                        sh "aws --profile eks configure set aws_secret_access_key ${env.AWS_ID_PSW}"
                        sh "terragrunt init"
                    }
                }
            }
        }
        stage("Terragrunt Plan") {
            steps {
                withAWS(credentials: "terraform-userpass", region: "eu-west-1") {
                    dir("kubernetes") {
                        sh "terragrunt plan -var-file=${env.VAR_FILE}"
                    }
                }
            }
        }
        stage("Confirm Provision") {
            steps {
                timeout(time: 120, unit: "SECONDS") { input "Confirm provision" }
            }
        }
        stage("Terragrunt Apply") {
            steps {
                script {
                    withAWS(credentials: "terraform-userpass", region: "eu-west-1") {
                        dir("kubernetes") {
                            if (params.action == 'apply') {
                                sh "terragrunt apply -input=false -auto-approve -var-file=${env.VAR_FILE}"
                            }
                        }
                    }
                }
            }
        }
        stage("Terragrunt Destroy") {   
            steps {
                script {
                    withAWS(credentials: "terraform-userpass", region: "eu-west-1") {
                        dir("kubernetes") {
                            if (params.action == 'destroy') {
                                sh "terragrunt destroy -input=false -auto-approve -var-file=${env.VAR_FILE}"
                            }
                        }
                    }
                }
            }
        }
    }
    post {
        always {
            cleanWs deleteDirs: true, notFailBuild: true
        }
    }
}