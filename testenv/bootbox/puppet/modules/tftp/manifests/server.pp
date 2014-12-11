class tftp::server {
  include tftp

  service {
    'xinetd':
      ensure  => running,
      enable  => true,
      require => File['/etc/xinetd.d/tftp'];
  }

  file {
    '/tftpboot':
      ensure => directory;
    '/etc/xinetd.d/tftp':
      source  => 'puppet:///modules/tftp/tftp.conf',
      require => File['/tftpboot'];
  }
}
