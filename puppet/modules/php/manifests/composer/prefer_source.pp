# == Define: php::composer::prefer_source
#
# Turn a composer library's directory into a git checkout (or back into
# a plain directory).
#
# === Parameters
#
# [*app_dir*]
#   The application directory where the composer.json file can be found.
#   This must be a php::composer::install directory.
#
# [*library*]
#   The library that should be turned into a git checkout.
#
# [*git_remote*]
#   Optionally, set a different git remote then what composer is using.
#   Needed for libraries which are developed on gerrit but their Composer
#   package refers to GitHub.
#
# [*vendor_dir*]
#   The vendor directory where Composer installs the libraries. Normally
#   this is $app_dir/vendor and can be omitted.
#
# [*prefer*]
#   Preferred source ('dist' or 'source'). Default 'source'.
#
define php::composer::prefer_source(
    $app_dir,
    $library,
    $git_remote = undef,
    $vendor_dir = undef,
    $prefer     = 'source',
) {
    require ::php::composer

    if ! ($prefer in ['dist', 'source']) {
        fail('prefer parameter must be dist or source')
    }

    $vendor_dir_real = $vendor_dir ? {
        undef   => "${app_dir}/vendor",
        default => $vendor_dir,
    }
    $library_dir = "${vendor_dir_real}/${library}"
    $safe_library_dir = regsubst($library_dir, '\W', '-', 'G')

    exec { "composer-prefer-source-rm-${safe_library_dir}":
        command => "rm -rf ${library_dir}",
        user    => 'vagrant',
        creates => "${library_dir}/.git",
        require => Php::Composer::Install[$app_dir],
    }

    exec { "composer-prefer-source-update-${safe_library_dir}":
        command     => "composer update --prefer-${prefer} ${library_dir}",
        cwd         => $app_dir,
        environment => [
            "COMPOSER_HOME=${::php::composer::home}",
            "COMPOSER_CACHE_DIR=${::php::composer::cache_dir}",
            'COMPOSER_NO_INTERACTION=1',
        ],
        user        => 'vagrant',
        creates     => $library_dir,
        subscribe   => Exec["composer-prefer-source-rm-${safe_library_dir}"],
    }

    if ($git_remote != undef) {
        exec { "composer-prefer-source-gitremote-${safe_library_dir}":
            command   => @("COMMAND")
                git remote set-url origin "${git_remote}"
                git remote set-url --push origin "${git_remote}"
                | COMMAND
            ,
            cwd       => $library_dir,
            user      => 'vagrant',
            subscribe => Exec["composer-prefer-source-update-${safe_library_dir}"],
        }
    }
}
