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

  file { 'joomla_sql_script':
    ensure   => file,
    path     => '/opt/joomla/setup_files/create_joomla_db.sql',
    content  => template('joomla/create_joomla_db.erb');
  }

  exec {
    'create_schema':
      path     => '/usr/bin:/usr/sbin:/bin',
      command  => 'mysql -uroot <\
                  /opt/joomla/setup_files/create_joomla_db.sql',
      unless   => "mysql -uroot -e \"use ${joomla::db_name}\"",
      notify   => Exec['grant_privileges'],
      require  => [
        Service[ $mysqlservice ],
        File['joomla_sql_script'],
      ];
    'grant_privileges':
      path         => '/usr/bin:/usr/sbin:/bin',
      command      => "mysql -uroot -e \"grant all privileges on\
                      ${joomla::db_name}.* to\
                      '${joomla::db_user}'@'localhost'\
                      identified by '${joomla::db_password}'\"",
      unless       => "mysql -u${joomla::db_user}\
                      -p${joomla::db_password}\
                      -D${joomla::db_name} -hlocalhost",
      refreshonly  => true;
  }
}
