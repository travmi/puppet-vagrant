#Puppet Vagrant

This vagrant file and configs are to be used with Adrien Thebo's Vagrant Oscar plugin.
Documentation of Oscar can be found here:
https://github.com/adrienthebo/oscar
https://github.com/adrienthebo/vagrant-pe_build
https://github.com/adrienthebo/vagrant-config_builder
https://github.com/adrienthebo/vagrant-auto_network

##Prequisites:
Virtualbox
Install Vagrant
Install Vagrant Oscar
tar.gz of a Puppet Enterprise installer

##Getting Started:
git clone https://github.com/travmi/puppet-vagrant
cd puppet-vagrant
vagrant up
You should have 2 VMs - master,agent

You will need to edit /etc/hosts to verify entries to either vm in order for puppet to work
puppet agent --test --debug

Check the IP of your master - eth1 should be accesible via your web browser which gives you access to the Enterprise console
https://<IP>

Recover the Puppet Enterprise Console Password:
# cd /opt/puppet/share/puppet-dashboard
# sudo /opt/puppet/bin/bundle exec /opt/puppet/bin/rake -s -f /opt/puppet/share/console-auth/Rakefile db:create_user USERNAME=admin@example.com PASSWORD=123456 ROLE="Admin" RAILS_ENV=production

Configure R10K for Environments:
# puppet module install zack/r10k

Create a .pp file to install and configure R10K:
```puppet
class { 'r10k':
  version           => '1.3.2',
  sources           => {
    'puppet' => {
      'remote'  => 'git@bitbucket.org:travmi/puppet-control.git',
      'basedir' => "${::settings::confdir}/environments",
      'prefix'  => false,
    },
    'hiera' => {
      'remote'  => 'git@bitbucket.org:travmi/hiera-control.git',
      'basedir' => "${::settings::confdir}/hiera",
      'prefix'  => false,
    }
  },
  purgedirs         => ["${::settings::confdir}/environments"],
  manage_modulepath => true,
  modulepath        => "${::settings::confdir}/environments/\$environment/modules:/opt/puppet/share/puppet/modules",
}
```

Verify /etc/r10k.yaml is configured properly

Create the environments folder and configure Puppet to use it. Restart pe-puppet.

configure /etc/puppetlabs/puppet/hiera.yaml
```
---
:backends:
  - json
:hierarchy:
  - "node/%{fqdn}"
  - "environment/%{environment}"
  - global
:json:
  :datadir: /etc/puppetlabs/puppet/hiera/%{environment}/
# /etc/puppetlabs/puppet/hieradata/
```
restart pe-puppet

create ssh keys on your new puppet master and add them to your bitbucket/github account
ssh-keygen -t rsa
restart sshd after creating/adding keys

Tweaks to /etc/puppetlabs/puppet/puppet.conf
Comment out modulepath under main

Change owner permissions on environments and hiera directories.
If this is not done you will get an error: Could not find data item classes in any Hiera data file and no default supplied
You will also need to check your facts on the agent to verify fqdn or hostname is there. If it is not you need to update hiera.yaml respectively.
chown -R root:pe-puppet /etc/puppetlabs/puppet/environments
chown -R root:pe-puppet /etc/puppetlabs/puppet/hiera

Intall the augeas module on the master:
puppet module install domcleal/augeasproviders
puppet module install puppetlabs/mount_providers
puppet module install herculesteam/augeasproviders
puppet module install herculesteam/augeasproviders_base
puppet module install herculesteam/augeasproviders_core
puppet module install herculesteam/augeasproviders_mounttab
puppet module install herculesteam/augeasproviders_nagios
puppet module install herculesteam/augeasproviders_ssh
puppet module install herculesteam/augeasproviders_syslog


install EPEL
rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm

install ruby-augeas
yum install ruby-augeas

restart pe-puppet on master

Found a problem with Apache module (init.pp) ::fqdn does not exist on the agent. Had to change to ::hostname.

Problem with mounttab provider - error given "augeas" provider not a provider.

Need resource collectors in place to apply repos before packages.
Epel, NGINX, Webtatic

Found out that fqdn does not show up until /etc/resolv.conf is filled out by puppet. Need to look into this

#Contributing:
Please fork and pull
Mike Travis 
