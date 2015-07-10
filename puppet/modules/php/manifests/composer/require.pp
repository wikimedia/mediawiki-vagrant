# == Define: php::composer::require
#
# Install a php package via composer.
#
# === Parameters
#
# [*version*]
#   Package version.
#
# [*directory*]
#   Directory containing composer.json to modify.
#
# [*prefer*]
#   Prefer source or dist. Default dist.
#
# [*dev*]
#   Add package to require-dev section of composer.json. Default false.
#
# [*ensure*]
#   What state the package should be in. Default 'present'.
#
# === Examples
#
#  php::composer::require { 'mediawiki/semantic-media-wiki':
#      version => '~1.9',
#  }
#
#  php::composer::require { 'squizlabs/php_codesniffer':
#      directory => $::mediawiki::dir,
#      version   => 'dev-master',
#      prefer    => 'source',
#      dev       => true,
#  }
#
define php::composer::require(
    $version,
    $directory,
    $prefer = 'dist',
    $dev    = false,
    $ensure = 'present',
) {
    require ::php::composer

    if ! ($prefer in ['dist', 'source']) {
        fail('prefer parameter must be dist or source')
    }

    if ! ($ensure in ['present', 'absent']) {
        fail('ensure parameter must be present or absent')
    }

    $safe_package = regsubst($title, '\W', '-', 'G')

    if $ensure == 'present' {
        exec { "composer-require-${safe_package}":
            command     => template('php/composer-require-command.erb'),
            unless      => "composer show --installed | grep -w '${title}'",
            cwd         => $directory,
            environment => [
                "COMPOSER_HOME=${::php::composer::home}",
                "COMPOSER_CACHE_DIR=${::php::composer::cache_dir}",
                'COMPOSER_NO_INTERACTION=1',
            ],
        }
    } else {
        exec { "composer-remove-${safe_package}":
            command     => template('php/composer-remove-command.erb'),
            onlyif      => "composer show --installed | grep -w '${title}'",
            cwd         => $directory,
            environment => [
                "COMPOSER_HOME=${::php::composer::home}",
                "COMPOSER_CACHE_DIR=${::php::composer::cache_dir}",
                'COMPOSER_NO_INTERACTION=1',
            ],
        }
    }
}
