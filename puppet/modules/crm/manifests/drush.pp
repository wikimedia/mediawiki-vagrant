# == Class: crm::drush
#
# Drush commandline Drupal manipulation
#
class crm::drush( $root, $dir ) {
    include ::crm

    php::composer::install { 'drush':
      directory => $dir,
      require   => Git::Clone['wikimedia/fundraising/crm/drush'],
    }

    # FIXME: Correctly handle path everywhere.
    $wrapper = '/usr/local/bin/drush'

    file { '/usr/bin/drush':
        ensure  => link,
        target  => "${dir}/drush",
        require => Git::Clone['wikimedia/fundraising/crm/drush']
    }

    file { $wrapper:
        ensure  => present,
        mode    => '0755',
        content => template('crm/drush-wrapper.sh.erb'),
    }

    git::clone { 'wikimedia/fundraising/crm/drush':
      directory => $dir
    }
}
