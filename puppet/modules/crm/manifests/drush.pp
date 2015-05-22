# == Class: crm::drush
#
# Drush commandline Drupal manipulation
#
class crm::drush( $root ) {
    include ::crm

    require_package('drush')

    file { '/usr/local/bin/drush':
        ensure  => present,
        mode    => '0755',
        content => template('crm/drush-wrapper.sh.erb'),
    }
}
