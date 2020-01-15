# == Class: role::mailgun
# Configures Mailgun extension
class role::mailgun {
  mediawiki::extension { 'Mailgun':
    composer => true,
    settings => template('role/mailgun/conf.php.erb')
  }
}
