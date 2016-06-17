#!/bin/bash

set -e -x

######### VARIABLES #########
NAME=$1 # the domain name
DOMAIN_EXT=$2 # the domain extension
ROLE=$3 # role of the node
APP_TIER=$4 # development, test, or production
HOSTING_LOCATION=$5 # vagrant, linode, aws
NODE_ID=$6 # unique number for agent cert
PUPPET_MASTER=$7 # pm.example.com

### DON'T EDIT BELOW THIS LINE ###

##### Node information ####
HOSTNAME="${NAME}.${DOMAIN_EXT}"
#--------------------------
##### Puppet Facts ####
## role: what work is done
APP_NAME="${NAME}_${ROLE}"
#--------------------------
##### Communication to puppetmaster ####
## id must be unique for the role & hostname
CERTNAME="${ROLE}_${NODE_ID}.${HOSTNAME}"
PUPPET_ENVIRONMENT=production
#----------------------------------------

export DEBIAN_FRONTEND=noninteractive

# set hostname & hosts
hostname $HOSTNAME
echo $HOSTNAME > /etc/hostname
echo "127.0.0.1 $HOSTNAME" >> /etc/hosts

### enable Puppet package repositories
wget https://apt.puppetlabs.com/puppetlabs-release-pc1-trusty.deb
sudo dpkg -i puppetlabs-release-pc1-trusty.deb
sudo apt-get update
export PATH=/opt/puppetlabs/bin:$PATH

### install puppet agent
apt-get -y install puppet-agent

### edit puppet.conf
echo "
[main]
certname = $CERTNAME
[agent]
server      = $PUPPETMASTER
environment = $PUPPET_ENVIRONMENT
" >> /etc/puppetlabs/puppet/puppet.conf

# add facter facts
mkdir -p /etc/facter/facts.d
echo "
application_tier=$APP_TIER
application_name=$APP_NAME
hosting_location=$HOSTING_LOCATION
" >> /etc/facter/facts.d/app.txt

### start puppet
sudo /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true
