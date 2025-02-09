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

The stack is structured into multiple layers / components:

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
```shell
./ctl.sh machines apply
```
Give the machines some time to bootstrap after the apply finishes, some of them 
will run cloud-init install various packages on the machines.  

2) Install and configure stack on all hosts
```shell
./ctl.sh system bootstrap
```

3) Configure VPN on cloud server and edge router
```shell
./ctl.sh network configure
```

4) Initialize Vault
At this stage, you need to initialize Vault by visiting `http://192.168.1.151:8200` in order to generate the unseal keys and the root token.
Set the root token as `VAULT_TOKEN` variable in your `.env`, for the next step will configure Vault secrets engines and policies.

5) Install and configure platform services on Nomad
```shell
./ctl.sh platform apply
```

6) Install apps on Nomad
```shell
./ctl.sh apps apply
```

## Migrate State to Consul

Configure in your `.env`:
```shell
export CONSUL_HTTP_ADDR="<a-server-ip>:8500"
```

Add the Consul backend to your Terraform config:
```hcl
terraform {
  backend "consul" {
    scheme = "http"
    path   = "terraform/hyper-forge/<module>"
  }
}
```

Then migrate state to Consul:

```shell
terraform init -migrate-state
```

You can just revert back into your local state by deleting the Consul backend from your Terraform config and run `migrate_state` again.  
This is usefull if you want to tear down the system or make changes to the Consul nodes.

## Move Secrets to Vault

After Vault is bootstrapped and unsealed, secrets can now be stored in Vault and loaded through Terraform, e.g.:
```hcl
data "vault_kv_secret_v2" "vaultwarden_secrets" {
  mount = "kv"
  name  = "apps/vaultwarden"
}
```