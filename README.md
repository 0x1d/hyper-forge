# Hyper-Forge

![overview](./docs/assets/Hyper-Forge.drawio.svg)

Hyper-Forge is an opinionated homelab stack with all the funky stuff:

- Hypervisor: Proxmox
- Workload Orchestrator: Nomad
- Network Storage: NFS
- Service Discovery: Consul
- Secrets Management: Vault
- Identity and Access Management: LDAP, Authelia
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
- Ansiblehcl
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

After the platform has been provisioned, make sure to set all secrets for the apps in Vault, see [Move Secrets to Vault](#move-secrets-to-vault).

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

After Vault is bootstrapped and unsealed, secrets can now be stored in Vault and loaded through Terraform.
Secrets are currently stored in this hierarchy, so make sure to set these secrets after `platform` has been provisioned, before deploying `apps`:
- kv
  - system
    - HCLOUD_TOKEN
    - HCLOUD_DNS_TOKEN
    - INGRESS_AUTH_TOKEN
  - apps
    - postress
      - PGADMIN_PASSWORD
      - POSTGRES_PASSWORD
    - vaultwarden
      - ADMIN_TOKEN

## PostgreSQL Server Security

With the default PostgreSQL server configuration in combination with the service mesh proxy, it is possible to connect to any DB without password, as the DB connection appears to be `local` and therefore trusted.  
To enforce a password check, modify `pg_hba.conf` to change the authentication method from "trust" to "md5", e.g.:

```
# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     md5
# IPv4 local connections:
host    all             all             127.0.0.1/32            md5
# IPv6 local connections:
host    all             all             ::1/128                 md5
```

## Troubleshooting

### Bridge Network

In case you encounter the message "missing network" when allocating a task, check if bridge network is enabled on the Nomad client nodes (should look like this):
```
lsmod | grep bridge

bridge                421888  1 br_netfilter
stp                    12288  1 bridge
llc                    16384  2 bridge,stp
```
If this is not the case, try to enable all required modules:
```
modprobe bridge
modprobe br_netfilter
```
They should however be enabled anyway through config located in `system/config/client/etc/modules-load.d` or `etc/modules-load.d` on the nodes themselves.  
  
You may also consult the Nomad CNI documentation: https://developer.hashicorp.com/nomad/docs/networking/cni#install-cni-reference-plugins
