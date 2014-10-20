define nginx::conf_d( $source = '', $content = '', $target ) {
  include nginx

  if $source != '' {
    file { "/etc/nginx/conf.d/${target}":
      source => $source,
    }
  } else {
    file { "/etc/nginx/conf.d/${target}":
      content => $content,
    }
  }

  # requirements
  File['/etc/nginx/conf.d'] -> File["/etc/nginx/conf.d/${target}"]

  # notifications
  File["/etc/nginx/conf.d/${target}"] ~> Service["nginx"]
} 

