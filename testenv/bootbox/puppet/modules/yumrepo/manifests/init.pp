class yumrepo {
  package {
    ['livecd-tools','createrepo','tito','mock']:
      ensure  => latest,
      require => File['/etc/yum.repos.d/epel.repo'];
  }

  file {
    '/etc/yum.repos.d/nginx.repo':
      source => 'puppet:///modules/yumrepo/nginx.repo';
    '/etc/yum.repos.d/ruby193.repo':
      source => 'puppet:///modules/yumrepo/ruby193.repo';
    '/etc/yum.repos.d/epel.repo':
      source => 'puppet:///modules/yumrepo/epel.repo';
  }
}
