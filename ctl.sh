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
		system ansible_run install
	}

	function configure {
		system ansible_run configure
	}

	function update {
		system ansible_run update
	}

	function restart {
		system ansible_run restart
	}

	function ansible_run {
		ANSIBLE_HOST_KEY_CHECKING=False \
			ansible-playbook -i system/target/inventory.cfg system/ansible/$1.yaml
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
