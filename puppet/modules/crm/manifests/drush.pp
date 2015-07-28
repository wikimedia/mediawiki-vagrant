# == Class: crm::drush
#
# Drush commandline Drupal manipulation
#
class crm::drush( $root ) {
    include ::crm

    require_package('drush')

    # FIXME: Correctly handle path everywhere.
    $wrapper = '/usr/local/bin/drush'

    file { $wrapper:
        ensure  => present,
        mode    => '0755',
        content => template('crm/drush-wrapper.sh.erb'),
    }
}
