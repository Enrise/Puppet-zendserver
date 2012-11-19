
class zendserver::package (
  $version = 'UNSET',
  $php_version,
  ) {
  
  include apt

  case $version {
    'UNSET',
      '6.0':     { $repo = "http://repos.zend.com/zend-server/6.0/beta/deb" }
    '5.6':         { $repo = "http://repos.zend.com/zend-server/deb" }
    default:       { raise Puppet::ParseError, "Unknown Zend Server version specified." }
  }

  apt::repository { "zend-server":
    url       => $repo,
    distro    => 'server',
    repository=> 'non-free',
    key       => "zp-infra@zend.com",
    key_url   => 'http://repos.zend.com/zend.key',
  }

  class { "php":
    package     => "zend-server-php-${php_version}",
    config_dir  => "/usr/local/zend/etc/",
    config_file => "/usr/local/zend/etc/php.ini",
    config_file_group => "zend",
  }

  class { "php::pear":
    package         => "zend-server-php-${php_version}",
    install_package => false,
    path            => '/usr/local/zend/bin:/usr/bin:/usr/sbin:/bin:/sbin',
  }
}
