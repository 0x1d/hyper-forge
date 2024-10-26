# Hyper-Forge

![overview](./docs/assets/Hyper-Forge.drawio.svg)

Hyper-Forge is an opinionated homelab stack with all the funky stuff:

- Hypervisor: Proxmox
- Workload Orchestrator: Nomad
- Network Storage: NFS
- Service Discovery: Consul
- Secrets Management: Vault
- Identity and Access Management: TBD
- Ingress & Load Balancing: Traeffik
- Virtual Private Network: Wireguard
- Monitoring: Prometheus, Grafana
- Backups: TBD

This repo contains a collection of Terraform configurations, Ansible playbooks, and other tools that together form a complete infrastructure automation stack. The goal of this project is to provide a reproducible and version-controlled way to deploy and manage a complex infrastructure environment.

The stack is structured into multiple layers:

- machines
- system
- network
- platform
- apps

## Prerequisites

- a working Proxmox Virtual Environment
- a NFS server
- a Hetzner Cloud API Key
- Terraform
- Ansible
- jq

## Setup

0) Create and configure `.env` file
```
export PROXMOX_VE_USERNAME="root@pam"
export PROXMOX_VE_PASSWORD="<your-password>"
export PROXMOX_VE_ENDPOINT="https://<pve-ip-addr>:8006/"
export HCLOUD_TOKEN="<your-hetzner-token>"
export TF_VAR_ssh_public_key="~/.ssh/id_rsa.pub"
export TF_VAR_dns_api_key="<cert-resolver-api-key>"
```

1) Provision virtual machines on Proxmox and Hetzner  
First, take a look at `config.tfvar` and change the configuration as needed.  
Then simply run:
```
./ctl.sh machines apply
```
Give the machines some time to bootstrap after the apply finishes, some of them 
will run cloud-init install various packages on the machines.  

After that you want to expose some variables from the state for the next provisioning steps by adding following variables to your `.env` file:  
```
export TF_VAR_wireguard_server_ip="$(terraform -chdir=machines output -json cloud_network | jq .wireguard_server_ip.ip_address -r)"

export TF_VAR_cloud_subnet_range="$(terraform -chdir=machines output -json cloud_network | jq .subnet.ip_range -r)"
```

2) Install and configure stack on all hosts
```
./ctl.sh system apply
```

3) Configure VPN on cloud server and edge router
```
./ctl.sh network apply
```

4) Install and configure platform services on Nomad
```
./ctl.sh platform apply
```

5) Install apps on Nomad
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