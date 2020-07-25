class webserver (
  $package_name = 'nginx',
  $service_name = $package_name,
  $doc_root = '/var/www/html',
) {
  package { $package_name:
    ensure => present,
  }
  service { $service_name:
    ensure => running,
    enable => true,
  }
  file { "$doc_root/index.$package_name-debian.html":
    source => "puppet:///modules/webserver/index.html",
  }
}
