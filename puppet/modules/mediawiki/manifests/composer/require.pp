# == Define: mediawiki::composer::require
#
# Install a MediaWiki depdendency via Composer.
#
# Creates a composer.json fragment suitable for including via
# composer-merge-plugin, and ensures composer update is called when needed.
#
# If the resource is removed, any previously installed packages will
# automatically get uninstalled.
#
# === Parameters
#
# [*name*]
#   Name of the package to be required. Defaults to the resource title,
#   but it is recommended to set it manually and use a more unique title
#   to avoid Puppet resource conflicts when two roles require the same package.
#
# [*version*]
#   Package version. See <http://qpleple.com/understand-composer-versions/>
#   for the version specification format.
#
# [*dev*]
#   Add package to require-dev section of composer.json. Default false.
#
# [*ensure*]
#   What state the package should be in. Default 'present'. Using 'absent'
#   will instruct composer to bail out with an error message if something
#   else tries to require the package.
#
# === Examples
#
#  mediawiki::composer::require { 'mediawiki/semantic-media-wiki for foo role':
#      package => 'mediawiki/semantic-media-wiki',
#      version => '~1.9',
#  }
#
#  mediawiki::composer::require { 'squizlabs/php_codesniffer for bar role':
#      package => 'squizlabs/php_codesniffer',
#      version => 'dev-master',
#      dev     => true,
#  }
#
define mediawiki::composer::require(
    $version,
    $package = $title,
    $dev     = false,
    $ensure  = 'present',
) {
    if ! ($ensure in ['present', 'absent']) {
        fail('ensure parameter must be present or absent')
    }

    $safe_title = regsubst($title, '\W', '-', 'G')
    file { "${::mediawiki::composer_fragment_dir}/${safe_title}.json":
        content => template('mediawiki/composer-require.json.erb'),
        notify  => Exec["composer update ${::mediawiki::dir}"],
    }
}

