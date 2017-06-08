class genesis{
  $testenv_dir = "/${::testenv}"
  $web_root = '/web'

  # needed so mock can be use to build RPMs
  user {'vagrant': groups => 'mock'}

  package {
    ['gcc', 'gcc-c++', 'libxslt-devel', 'libxml2-devel', 'ruby-devel']:
      ensure  => present,
      require => File['/etc/yum.repos.d/ruby193.repo'];
    # sinatra contrib needs tilt
    'tilt':
      ensure => '1.3',
      provider => gem,
      require => Package['ruby-devel'];
    ['sinatra', 'unicorn']:
      provider => gem,
      require => Package['ruby-devel'];
    'sinatra-contrib':
      provider => gem,
      require  => Package['tilt'];
  }

  service {
    'genesis':
      ensure    => running,
      enable    => true,
      hasstatus => true,
      require   => File[$web_root];
  }

  file {
    ['/var/log/genesis', '/var/run/genesis']:
      ensure => directory,
      mode   => '0755',
      owner  => daemon;
    [$web_root, '/genesis']: # vagrant creates these
      ensure => directory;
    '/etc/init.d/genesis':
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      source  => 'puppet:///modules/genesis/genesis.init',
      notify  => Service['genesis'],
      require => Package['unicorn'];
    "${web_root}/tasks":
      ensure  => link,
      target  => '/genesis/tasks',
      require => File['/genesis'];

    $testenv_dir:
      ensure => directory;
    "${testenv_dir}/config.yaml":
      content => template('genesis/config.yaml.erb'),
      require => File[$testenv_dir];
    "${testenv_dir}/menu.ipxe":
      content => template('genesis/menu.ipxe.erb'),
      require => File[$testenv_dir];
    "${testenv_dir}/stage2":
      content => template('genesis/stage2.erb'),
      require => File[$testenv_dir];
  }

  Package['sinatra'] -> Package['unicorn'] -> Service['genesis']
}
