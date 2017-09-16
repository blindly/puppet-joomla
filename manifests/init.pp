class joomla(
                $db_name='joomla',
                $db_user='joomla',
                $db_password='password',
                $major_version='3-7.5',
                $version='3-7-5',
                )
{
  include joomla::app
  include joomla::db
}
