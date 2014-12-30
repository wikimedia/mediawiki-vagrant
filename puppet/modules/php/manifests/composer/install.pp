# == Define: php::composer::install
#
# Install dependencies declared in a composer.json file.
#
# === Parameters
#
# [*directory*]
#   Directory containing composer.json to modify. Default $title.
#
# === Examples
#
#  php::composer::install { $::mediawiki::dir:
#      require => Git::Clone['mediawiki/core'],
#  }
#
define php::composer::install(
    $directory = $title,
) {
    require ::php::composer

    $safe_dir = regsubst($directory, '\W', '-', 'G')

    exec { "composer-install-${safe_dir}":
        command     => 'composer install --optimize-autoloader',
        cwd         => $directory,
        environment => [
          "COMPOSER_HOME=${::php::composer::home}",
          "COMPOSER_CACHE_DIR=${::php::composer::cache_dir}",
          'COMPOSER_NO_INTERACTION=1',
        ],
        user        => 'vagrant',
        creates     => "${directory}/composer.lock",
        require     => [
            Class['::php::composer'],
        ],
    }
}
