# == Define: php::composer::install
#
# Install dependencies declared in a composer.json file.
#
# === Parameters
#
# [*directory*]
#   Directory containing composer.json to provision. Default $title.
#
# [*vendor_dir*]
#   Directory that composer provisions vendor libraries to. Default
#   $directory/vendor.
#
# [*prefer*]
#   Specify preferred source for composer install ('dist' or 'source').
#   Default 'dist'.
#
# === Examples
#
#  php::composer::install { $::mediawiki::dir:
#      require => Git::Clone['mediawiki/core'],
#  }
#
define php::composer::install(
    $directory  = $title,
    $vendor_dir = undef,
    $prefer     = 'dist',
) {
    require ::php::composer

    if ! ($prefer in ['dist', 'source']) {
        fail('prefer parameter must be dist or source')
    }

    $safe_dir = regsubst($directory, '\W', '-', 'G')
    $creates = $vendor_dir ? {
        undef   => "${directory}/vendor",
        default => $vendor_dir,
    }

    exec { "composer-install-${safe_dir}":
        # lint:ignore:80chars
        command     => "composer install --optimize-autoloader --prefer-${prefer}",
        # lint:endignore
        cwd         => $directory,
        environment => [
          "COMPOSER_HOME=${::php::composer::home}",
          "COMPOSER_CACHE_DIR=${::php::composer::cache_dir}",
          'COMPOSER_NO_INTERACTION=1',
        ],
        user        => 'vagrant',
        creates     => $creates,
        require     => [
            Class['::php::composer'],
        ],
    }
}
