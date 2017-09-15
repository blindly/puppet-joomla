class joomla(
                $db_name='joomla',
                $db_user='joomla',
                $db_password='password'
                )
{  
  class {'joomla::app':
  
  }
  
  class { 'joomla::db':
    db_name = $db_name,
    db_user = $db_user,
    db_password = $db_password,
  }
}
