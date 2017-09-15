# Install joomla application and its dependencies
class joomla::app {

  $joomla_archive = 'Joomla_3-7.5-Stable-Full_Package.zip'
  
  $install_directory = '/var/www/html'
  
  $apache = $::operatingsystem ? {
    Ubuntu   => apache2,
    CentOS   => httpd,
    Debian   => apache2,
    default  => httpd
  }

  $phpmysql = $::operatingsystem ? {
    Ubuntu   => php-mysql,
    CentOS   => php-mysql,
    Debian   => php5-mysql,
    default  => php-mysql
  }
  
  $phpxml = $::operatingsystem ? {
    Ubuntu   => php-xml,
    CentOS   => php-xml,
    Debian   => php5-xml,
    default  => php-xml
  }
  
  $phpmcrypt = $::operatingsystem ? {
    Ubuntu   => php-mcrypt,
    CentOS   => php-mcrypt,
    Debian   => php5-mcrypt,
    default  => php-mcrypt
  }
  
  $php = $::operatingsystem ? {
    Ubuntu   => libapache2-mod-php,
    CentOS   => php,
    Debian   => libapache2-mod-php5,
    default  => php
  }
  
  $www_user = $::operatingsystem ? {
    Ubuntu   => www-data,
    CentOS   => www-data,
    Debian   => www-data,
    default  => www-data
  }
  
  $www_group = $::operatingsystem ? {
    Ubuntu   => www-data,
    CentOS   => apache,
    Debian   => www-data,
    default  => www-data
  }

  package { ['unzip',$apache,$php,$phpmysql,$phpxml,$phpmcrypt]:
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
  
  exec{'retrieve_joomla':
    command => "/usr/bin/wget -q http://downloads.joomla.org/cms/joomla3/3-7-5/${joomla_archive}?format=zip -O /opt/joomla/setup_files/${joomla_archive}",
    creates => "/opt/joomla/setup_files/${joomla_archive}",
  }

  file {
    'joomla_application_dir':
      ensure  =>  directory,
      path    =>  '/opt/joomla',
      before  =>  File['joomla_setup_files_dir'];
    'joomla_setup_files_dir':
      ensure  =>  directory,
      path    =>  '/opt/joomla/setup_files',
      before  =>  File['joomla_installer'];
    'joomla_installer':
      mode    =>  0755,
      ensure  =>  file,
      path    =>  "/opt/joomla/setup_files/${joomla_archive}",
      notify  =>  Exec['joomla_extract_installer'],
      require  =>  Exec['retrieve_joomla'];
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
                        -d ${install_directory}",
        refreshonly  => true,
        require      => Package['unzip'],
        path         => ['/bin','/usr/bin','/usr/sbin','/usr/local/bin'];
  }
  
  file { 'install_directory':
    ensure => directory,
    path => $install_directory,
    owner => $www_user,
    group => $www_group,
  }
}
