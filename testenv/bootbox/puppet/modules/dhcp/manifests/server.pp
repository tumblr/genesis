class dhcp::server {
  
  include dhcp

  file { "/etc/dhcp/dhcpd.conf":
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    content => template('dhcp/dhcpd.conf.erb');
  }

  service { 'dhcpd':
    enable  => true,
    ensure  => running
  }

  Package['dhcp'] -> File["/etc/dhcp/dhcpd.conf"]
  File ["/etc/dhcp/dhcpd.conf"] ~> Service['dhcpd']
}
