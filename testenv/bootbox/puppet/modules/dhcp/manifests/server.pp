class dhcp::server {
  include dhcp

  file { '/etc/dhcp/dhcpd.conf':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('dhcp/dhcpd.conf.erb');
  }

  service { 'dhcpd':
    ensure  => running,
    enable  => true,
    require => File['/etc/dhcp/dhcpd.conf'];
  }

  Package['dhcp'] -> File['/etc/dhcp/dhcpd.conf']
}
