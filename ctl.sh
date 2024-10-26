#!/usr/bin/env bash

set -e

## Hyper-Forge
##
## Usage: ./ctl.sh COMMAND
##
## machines
##   apply            Provision machines
##
## system
##   apply            Install and configure systems
##   install          Install stack on hosts
##   configure        Configure hosts
##   update           Update packages on hosts
##   hosts <plabook>  Run playbook on hosts
##
## platform
##   apply            Apply platform services
##
## network
##   apply            Apply network configuration
##
## apps
##   apply            Install apps

source .env

function info {
	sed -n 's/^##//p' ctl.sh
}

function machines {
	function apply {
		tf_apply machines
	}
	function destroy {
		tf_destroy machines
	}
	${@:-info}
}

function system {
	function apply {
		tf_apply system
		system install
		system configure
		system update
	}
	function install {
		ansible_run system install
	}

	function configure {
		tf_apply system
		ansible_run system configure
	}

	function update {
		ansible_run system update
	}

	function restart {
		ansible_run system restart
	}
	${@:-info}
}

function network {
	function apply {
		tf_apply network
		ansible_run network configure
	}
	function update {
		ansible_run network update
	}
	${@:-info}
}

function platform {
	function apply {
		tf_apply platform
	}
	${@:-info}
}

function apps {
	function apply {
		tf_apply apps
	}
	${@:-info}
}

function ansible_run {
	ANSIBLE_HOST_KEY_CHECKING=False \
		ansible-playbook -i $1/target/inventory.cfg $1/ansible/$2.yaml
}

function tf_apply {
	pushd $1
		terraform init
		terraform apply -var-file=../config.tfvars
	popd
}

function tf_destroy {
	pushd $1
		terraform destroy -var-file=../config.tfvars
	popd
}



${@:-info}
