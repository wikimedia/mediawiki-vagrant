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
    $vendor_dir_real = $vendor_dir ? {
        undef   => "${directory}/vendor",
        default => $vendor_dir,
    }
    $creates = "${vendor_dir_real}/composer"

    exec { "composer-install-${safe_dir}":
        command     => "/usr/local/bin/composer install --optimize-autoloader --prefer-${prefer}",
        cwd         => $directory,
        environment => [
          "COMPOSER_HOME=${::php::composer::home}",
          "COMPOSER_CACHE_DIR=${::php::composer::cache_dir}",
          'COMPOSER_NO_INTERACTION=1',
          'COMPOSER_PROCESS_TIMEOUT=600',
        ],
        user        => 'vagrant',
        onlyif      => "/usr/bin/test -f ${directory}/composer.json",
        creates     => $creates,
        require     => Class['::php::composer'],
    }
}
