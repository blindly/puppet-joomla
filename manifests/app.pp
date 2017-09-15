# Install joomla application and its dependencies
class joomla::app {

  $joomla_archive = 'Joomla_3-7.5-Stable-Full_Package.zip'
  
  $apache = $::operatingsystem ? {
    Ubuntu   => apache2,
    CentOS   => httpd,
    Debian   => apache2,
    default  => httpd
  }

  $phpmysql = $::operatingsystem ? {
    Ubuntu   => php5-mysql,
    CentOS   => php-mysql,
    Debian   => php5-mysql,
    default  => php-mysql
  }

  $php = $::operatingsystem ? {
    Ubuntu   => libapache2-mod-php5,
    CentOS   => php,
    Debian   => libapache2-mod-php5,
    default  => php
  }

  package { ['unzip',$apache,$php,$phpmysql]:
    ensure => latest
  }

  $vhost_path = $apache ? {
    httpd    => '/etc/httpd/conf.d/joomla.conf',
    apache2  => '/etc/apache2/sites-enabled/000-default',
    default  => '/etc/httpd/conf.d/joomla.conf',
  }

  service { $apache:
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package[$apache, $php, $phpmysql],
    subscribe  => File['joomla_vhost'];
  }

  file {
    'joomla_application_dir':
      ensure  =>  directory,
      path    =>  '/opt/joomla',
      before  =>  File['joomla_setup_files_dir'];
    'joomla_setup_files_dir':
      ensure  =>  directory,
      path    =>  '/opt/joomla/setup_files',
      before  =>  File[
                      'joomla_installer',                      
                      ];
    'joomla_installer':
      ensure  =>  file,
      path    =>  "/opt/joomla/setup_files/${joomla_archive}",
      notify  =>  Exec['joomla_extract_installer'],
      source  =>  "puppet:///modules/joomla/${joomla_archive}";
    'joomla_vhost':
      ensure   => file,
      path     => $vhost_path,
      source   => 'puppet:///modules/joomla/joomla.conf',
      replace  => true,
      require  => Package[$apache];
    }
      exec {
      'joomla_extract_installer':
        command      => "unzip -o\
                        /opt/joomla/setup_files/${joomla_archive}\
                        -d /opt/",
        refreshonly  => true,
        require      => Package['unzip'],
        path         => ['/bin','/usr/bin','/usr/sbin','/usr/local/bin'];
  }
}
