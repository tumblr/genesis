class tftp::server {
  
  include tftp
  
  service {
    'xinetd':
      enable  => true,
      ensure  => running;
  }

  file {
    '/etc/xinetd.d/tftp':
      source => 'puppet:///modules/tftp/tftp.conf';
    '/tftpboot':
      ensure => directory;
  }
  
  File['/tftpboot'] -> File['/etc/xinetd.d/tftp'] ~> Service['xinetd']
}
