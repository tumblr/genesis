class iptables {
  file {
    '/etc/sysconfig/iptables':
      owner  => 'root',
      group  => 'root',
      mode   => '0600',
      source => 'puppet:///modules/iptables/iptables';
    '/etc/sysctl.conf':
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => 'puppet:///modules/iptables/sysctl.conf';
  }

  service {
    'iptables':
      enable => true,
  }

  exec {
    'sysctl_refresh':
      command => 'sysctl -p',
      path    => '/sbin',
      require => File['/etc/sysctl.conf'];
  }

  File['/etc/sysconfig/iptables'] ~> Service['iptables']
}
