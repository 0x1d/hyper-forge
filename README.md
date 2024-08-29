# Hyper-Forge

This is a collection of Terraform configurations, Ansible playbooks, and other tools that together form a complete infrastructure automation stack. The goal of this project is to provide a reproducible and version-controlled way to deploy and manage a complex infrastructure environment.

The stack consists of the following components:

- Proxmox: A type-1 hypervisor for running virtual machines
- Terraform: Used for provisioning and managing nodes
- Cloud-Init: Used for automating the initialization of nodes
- Ansible: Used for automating the configuration of nodes
- Consul: Used for service discovery and configuration management
- Nomad: A workload orchestrator for deploying and scaling containerized workloads
- Vault: A secure secrets management system

## Prerequisites

- a working Proxmox Virtual Environment
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
