class selinux::permissive {
  exec { 'set selinux permissive mode':
    command => '/usr/sbin/setenforce 0',
    onlyif  => '/usr/sbin/sestatus | /bin/egrep "Current mode: +enforcing"';
  }
}
