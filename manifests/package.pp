
class zendserver::package (
  $version = 'UNSET',
  $php_version,
  ) {
  
  include apt

  case $version {
    'UNSET',
    '5.6':         { $repo = "http://repos.zend.com/zend-server/deb" }
    default:       { $repo = "http://repos.zend.com/zend-server/$version/deb" }
  }

  apt::repository { "zend-server":
    url       => $repo,
    distro    => 'server',
    repository=> 'non-free',
    key       => "zp-infra@zend.com",
    key_url   => 'http://repos.zend.com/zend.key',
  }

#  exec { "apt-get update": }

}
