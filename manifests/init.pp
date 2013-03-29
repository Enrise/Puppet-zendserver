class zendserver (
  $version             = 6.0,
  $php_version         = 5.4,
  $firewall            = params_lookup( 'firewall' , 'global' ),
  $firewall_tool       = params_lookup( 'firewall_tool' , 'global' ),
  $firewall_src        = params_lookup( 'firewall_src' , 'global' ),
  $firewall_dst        = params_lookup( 'firewall_dst' , 'global' ),
  ) {
   
  $bool_firewall=any2bool($firewall)
  if $zendserver::bool_absent == true or $zendserver::bool_disable == true {
    $manage_firewall = false
  } else {
    $manage_firewall = true
  }
    

    class { 'zendserver::package' :
      version     => $version,
      php_version => $php_version,
    }

    ->

    exec {"zendserver_aptgetupdate":
        command   => "apt-get update"
        onlyif    => '/bin/bash -c x=$(apt-cache policy | grep \'${zendserver::package::repo}\' | wc -l); test "$x" = "0"'
    }

    ->

    class { "php":
      package     => "zend-server-php-${php_version}",
      config_dir  => "/usr/local/zend/etc/",
      config_file => "/usr/local/zend/etc/php.ini",
      config_file_group => "zend"
    }

    ->

    class { "php::pear":
      package         => "zend-server-php-${php_version}",
      install_package => false,
      path            => '/usr/local/zend/bin:/usr/bin:/usr/sbin:/bin:/sbin',
    }

    ->

    file { "zend-path" :
      path   => "/etc/profile.d/zend.sh",
      source => "puppet:///modules/zendserver/path.sh",
      owner  => "root",
      group  => "root",
      mode   => 0644,
    }

    ->

    file { "/var/log/zend":
      owner  => zend,
      group  => zend,
      ensure => directory,
      mode   => 775,
    }

    ->

    exec { "mv /usr/local/zend/var/log /var/log/zend/zendserver":
      onlyif => "/bin/sh -c '[ -d /usr/local/zend/var/log -a ! -h /usr/local/zend/var/log ]'",
    }

    ->

    file { "/usr/local/zend/var/log":
      ensure => link,
      target => "/var/log/zend/zendserver",
      force => true,
    }

    ->

    exec { "mv /usr/local/zend/tmp/* /tmp/":
      onlyif => "/bin/sh -c '[ -d /usr/local/zend/tmp -a ! -h /usr/local/zend/tmp ]'",
    }

    ->

  file { "/usr/local/zend/tmp":
    ensure => link,
    target => "/tmp",
    force => true,
  }


  #
  # Firewall
  #
  if $zendserver::bool_firewall == true {
    firewall { "zendserver_tcp_10081":
      source        => $zendserver::firewall_src,
      destination   => $zendserver::firewall_dst,
      protocol      => 'tcp',
      port          => 10081,
      action        => 'allow',
      direction     => 'input',
      tool          => $zendserver::firewall_tool,
      enable        => $zendserver::manage_firewall,
    }
    
    firewall { "zendserver_tcp_10082":
      source        => $zendserver::firewall_src,
      destination   => $zendserver::firewall_dst,
      protocol      => 'tcp',
      port          => 10082,
      action        => 'allow',
      direction     => 'input',
      tool          => $zendserver::firewall_tool,
      enable        => $zendserver::manage_firewall,
    }
  }


  # TODO Should this be here like that?  
  include zendserver::service
  
}
