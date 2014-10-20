class bind {
  package { 
    ['bind-sdb', 'bind', 'bind-chroot']: ensure => latest 
  }
}

