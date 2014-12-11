# This module manages a Ruby gem server.
#
# Parameters:
#  @port - space-separated string listing ports for gemserver to listen on
#
# Actions:
#
# Requires:
#
# [Remember: No empty lines between comments and class definition]
class gemserver (
  $ports = '8808'
) {

  file { '/etc/init.d/gemserver':
    content => template('gemserver/gemserver.erb'),
    mode    => '0755',
    owner   => 'root',
  }

  service { 'gemserver':
    ensure  => running,
    enable  => true,
    require => File['/etc/init.d/gemserver'];
  }
}
