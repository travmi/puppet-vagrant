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
  manage_modulepath => false,
  modulepath        => "${::settings::confdir}/environments/\$environment/modules:/opt/puppet/share/puppet/modules",
}