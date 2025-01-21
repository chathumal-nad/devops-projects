#!/bin/sh
sudo apt update -y
# sudo apt install ansible -y
sudo apt install software-properties-common -y
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible -y