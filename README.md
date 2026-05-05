
# Packer Nginx + Node.js - Multi-Cloud Deployment

Automated deployment of a Node.js application with Nginx as a reverse proxy using Packer. The project builds machine images for both AWS (AMI) and Azure (Managed Image) from a single template.

## Project Structure

- `main.pkr.hcl` - Packer template with builders for AWS and Azure
- `install.sh` - Provisioning script (Node.js, PM2, Nginx)
- `deploy.sh` - Automated deployment script using AWS CLI

## Requirements

- Packer
- AWS CLI configured with credentials
- Azure CLI (for multi-cloud builder)
- AWS account (Free Tier eligible)
- Azure account

## Usage

### Build images (AWS + Azure)

```
packer init main.pkr.hcl
packer validate main.pkr.hcl
packer build main.pkr.hcl
```

### Build only AWS

```
packer build -only=amazon-ebs.ubuntu main.pkr.hcl
```

### Build only Azure

```
packer build -only=azure-arm.ubuntu main.pkr.hcl
```

### Deploy instance on AWS

```
./deploy.sh
```

## Cloud Configuration

### AWS
- Region: eu-west-1 (Ireland)
- Instance type: t3.micro (Free Tier)
- Base image: Ubuntu 22.04 LTS (HVM, EBS)

### Azure
- Region: westeurope
- VM size: Standard_B1s
- Base image: Ubuntu 22.04 LTS (Canonical)

## Tech Stack

- Ubuntu 22.04 LTS
- Node.js 18 LTS
- PM2 (process manager)
- Nginx (reverse proxy)

