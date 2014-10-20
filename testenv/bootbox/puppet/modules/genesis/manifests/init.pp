class genesis{
  # gems
  package {
    ['gcc', 'gcc-c++', 'libxslt-devel', 'libxml2-devel', 'ruby-devel']:
      ensure => present,
      require => File['/etc/yum.repos.d/ruby193.repo'];
    ['sinatra', 'sinatra-contrib', 'unicorn']:
      provider => gem,
      require => Package['ruby-devel'];
  }

  # nginx
  $web_root = "/genesis/web"

  nginx::conf_d {
    'genesis': 
      target  => 'genesis.conf',
      content => template('nginx/rackapp.conf_d.erb');
  }

  service {
    "genesis":
      ensure    => running,
      enable    => true,
      hasstatus => true;
  }

  file {
    ['/var/log/genesis', '/var/run/genesis']:
      ensure => directory,
      mode   => 755,
      owner  => daemon;
    ['/genesis/web']:
      ensure => directory;
    "/etc/init.d/genesis":
      owner   => "root",
      group   => "root",
      mode    => "0755",
      source => "puppet:///modules/genesis/genesis.init",
      notify  => Service["genesis"],
      require => Package['unicorn'];
  }

  Package['sinatra'] -> Package['unicorn'] -> Service['genesis']
}

