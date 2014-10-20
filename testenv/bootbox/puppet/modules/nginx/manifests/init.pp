class nginx {
    require yumrepo

    package {
        'nginx': ensure => latest
    }

    service { 'nginx':
        ensure  => running,
        enable  => true;
    }

    file {
        '/etc/nginx/conf.d':
            ensure  => directory,
            owner   => nginx;
        '/var/log/nginx':
            ensure  => directory,
            owner   => 'nginx',
            group   => 'nginx',
            mode    => 775;
        "/usr/share/nginx/html/index.html":
            owner   => 'nginx',
            group   => 'nginx',
            mode    => 644,
            source => "puppet:///modules/nginx/index.html",
    }
}
