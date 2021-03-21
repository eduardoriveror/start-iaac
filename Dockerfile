FROM debian:stable-slim

# ARG TERRAFORM_VERSION
ARG TERRAGRUNT_VERSION=0.28.15
ARG TERRAFORM_VERSION=0.13.4

RUN \
	# Update
	apt-get update -y && \
	# Install dependencies
	apt-get install unzip wget curl vim git -y

################################
# Install Terraform
################################

# # Download terraform for linux
RUN wget  https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN \
# 	# Unzip
	unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
# 	# Move to local bin
	mv terraform /usr/local/bin/ && \
# 	# Make it executable
	chmod +x /usr/local/bin/terraform && \
# 	# Check that it's installed
	terraform --version

# ################################
# # Install tfenv
# ################################

# RUN \
# 	git clone https://github.com/tfutils/tfenv.git ~/.tfenv && \
# 	ln -s ~/.tfenv/bin/* /usr/local/bin
# 	# chmod 711 /usr/local/bin/tfenv

################################
# Install aws-cli
################################

RUN \
	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
	unzip awscliv2.zip && \
	./aws/install

################################
# Install Terragrunt
################################

# Download terraform for linux
RUN wget https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64

RUN \
	# Move to local bin
	mv terragrunt_linux_amd64 /usr/local/bin/terragrunt && \
	# Make it executable
	chmod +x /usr/local/bin/terragrunt && \
	# Check that it's installed
	terragrunt --version
