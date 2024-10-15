#!/usr/bin/env bash
set -e
apt update
apt upgrade -y
apt install -y curl wget vim tmux htop resolvconf gpg
