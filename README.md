# Hyper-Forge

Hyper-Forge is an opinionated homelab stack with all the funky stuff:

- Hypervisor
- Workload Orchestrator
- Service Discovery
- Secrets Management
- Identity and Access Management
- Ingress & Load Balancing
- Monitoring
- Backups

This repo contains a collection of Terraform configurations, Ansible playbooks, and other tools that together form a complete infrastructure automation stack. The goal of this project is to provide a reproducible and version-controlled way to deploy and manage a complex infrastructure environment.

The stack is structured into multiple layers:

- machines
- system
- platform
- apps

## Prerequisites

- a working Proxmox Virtual Environment
- a NFS server
- Terraform
- Ansible

## Setup

0) Create and configure `.env` file
```
export PROXMOX_VE_USERNAME="root@pam"
export PROXMOX_VE_PASSWORD="<your-password>"
export PROXMOX_VE_ENDPOINT="https://<pve-ip-addr>:8006/"
export TF_VAR_ssh_public_key="~/.ssh/id_rsa.pub"
export TF_VAR_dns_api_key="<cert-resolver-api-key>"
```

1) Provision virtual machines on Proxmox  
First, take a look at `machines.tf` and change the configuration as needed.  
Then simply run:
```
./ctl.sh machines apply
```

2) Install and configure stack on all hosts
```
./ctl.sh system apply
```

3) Install and configure platform services on Nomad
```
./ctl.sh platform apply
```

4) Install apps on Nomad
```
./ctl.sh apps apply
```

## Migrate State to Consul

Configure in your `.env`:
```
export CONSUL_HTTP_ADDR="<a-server-ip>:8500"
```

Add the Consul backend to your Terraform config:
```
terraform {
  backend "consul" {
    scheme = "http"
    path   = "terraform/playground"
  }
}
```

Then migrate state to Consul:

```
terraform init -migrate-state
```

You can just revert back into your local state by deleting the Consul backend from your Terraform config and run `migrate_state` again.