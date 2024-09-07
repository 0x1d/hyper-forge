#!/usr/bin/env bash

set -e

## Hyper-Forge
##
## Usage: ./ctl.sh COMMAND
##
## provision        Apply Terraform config
## install          Install stack on hosts
## configure        Configure hosts
## update           Update packages on hosts
## hosts <plabook>  Run playbook on hosts
## migrate_state    Migrate Terraform state


source .env

function info {
	sed -n 's/^##//p' ctl.sh
}

function provision {
	terraform init
	terraform apply
}

function install {
	hosts install
}

function configure {
	hosts configure
}

function update {
	hosts update
}

function hosts {
	ansible_run $1
}

function migrate_state {
	terraform init -migrate-state
}

function ansible_run {
	ANSIBLE_HOST_KEY_CHECKING=False \
		ansible-playbook -i target/inventory.cfg ansible/$1.yaml
}

${@:-info}
