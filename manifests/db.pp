# Install mysql server and set up joomla database
class joomla::db {

  $mysqlserver = $::operatingsystem ? {
    Ubuntu   => mysql-server,
    CentOS   => mysql-server,
    default  => mysql-server
  }

  $mysqlclient = $::operatingsystem ? {
    Ubuntu   => mysql-client,
    CentOS   => mysql,
    Debian   => mysql-client,
    default  => mysql
  }

  $mysqlservice = $::operatingsystem ? {
    Ubuntu   => mysql,
    CentOS   => mysqld,
    Debian   => mysql,
    default  => mysqld
  }

  package { [ $mysqlclient, $mysqlserver ]: ensure => latest }

  service { $mysqlservice:
    ensure      => running,
    enable      => true,
    hasrestart  => true,
    hasstatus   => true,
    require     => Package[ $mysqlserver, $mysqlclient ],
  }

}
