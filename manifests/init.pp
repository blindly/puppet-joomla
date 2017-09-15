import '*.pp'
# Install and configure wordpress and its dependencies
class joomla(
                $db_name='joomla',
                $db_user='joomla',
                $db_password='password'
                )
{
  include joomla::app
  include joomla::db
}
