class bind::server {

  include bind

  service {
    'named':
        ensure  => running,
        enable  => true;
  }

  Service['named'] -> Package['bind-chroot']
}
