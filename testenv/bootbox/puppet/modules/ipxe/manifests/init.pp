class ipxe {
  require tftp::server

  $tftproot = '/tftpboot'

  File { owner => root, group => root, mode => 0644 }
  file {
    "${tftproot}/undionly.kpxe":
      ensure => present,
      source => 'puppet:///modules/ipxe/undionly.kpxe';
  }
}

