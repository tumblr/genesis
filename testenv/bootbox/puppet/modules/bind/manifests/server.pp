class bind::server {

  include bind

  service {
    'named':
        enable  => true,
        ensure  => running,
  }

  Service['named'] -> Package['bind-chroot']
}
