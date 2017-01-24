# class role::commons_datasets
# Allows to store tabular/spatial data on Commons to be used by Kartographer
# See https://www.mediawiki.org/wiki/Help:Tabular_Data
#
# [*commons_url*]
#   Full URL to api.php of wiki to use as central repository for datasets
#
class role::commons_datasets (
    $commons_url,
) {
  include ::role::jsonconfig
  include ::role::commons

  mediawiki::settings { 'commons_datasets':
      values => template('role/commons_datasets/settings.php.erb'),
  }
}
