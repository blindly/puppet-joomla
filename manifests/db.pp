# Install mysql server and set up joomla database
class joomla::db (
                $db_name='joomla',
                $db_user='joomla',
                $db_password='password'
) {

  class { '::mysql::server': }
  
  mysql::db { $db_name:
    user     => $db_user,
    password => $db_password,
    host     => 'localhost',
    grant    => ['*'],
  }

}
