# Hyper-Forge

Hyper-Forge is an opinionated homelab stack with all the funky stuff:

- Hypervisor
- Workload Orchestrator
- Service Discovery
- Secrets Management
- Identity and Access Management
- Load Balancing
- Monitoring
- Backups

This repo contains a collection of Terraform configurations, Ansible playbooks, and other tools that together form a complete infrastructure automation stack. The goal of this project is to provide a reproducible and version-controlled way to deploy and manage a complex infrastructure environment.

Tools used:

- Terraform: Used for provisioning and managing nodes
- Cloud-Init: Used for automating the initialization of nodes
- Ansible: Used for automating the configuration of nodes

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
```

1) Provision virtual machines on Proxmox  
First, take a look at `machines.tf` and change the configuration as needed.  
Then simply run:
```
./ctl.sh provision
```

2) Install stack on all hosts
```
./ctl.sh install
```

3) Configure stack on all hosts
```
./ctl.sh configure
```

4) Update all packages and reboot
```
./ctl.sh update
```

## Ascendance of State

If you like what you got, you may want to migrate your Terraform state to Consul.
This will move your local Terraform state to Consul to make it distributed, so you can make changes to the infrastructure from anywhere.
From there is no come back, your state will ascend into the infrastructure you just provisioned.  

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
./ctl.sh migrate_state
```

Ok I lied; you can just revert back into your local state by deleting the Consul backend from your Terraform config and run `migrate_state` again.

## Deployment of Apps

As we're using Nomad as the workload orchestrator, we will also use Terraform to deploy our Nomad HCL deployment configs.
