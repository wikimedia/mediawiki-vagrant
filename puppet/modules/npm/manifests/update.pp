# == Define: npm::update
#
# Custom resource for installing / updating node.js module dependencies
#
# === Parameters
#
# [*directory*]
#   Name of the directory where to execute the install/update
#
# [*unless*]
#   Condition to use to test if the update should be executed
#
define npm::update(
    $directory,
    $unless     = undef,
) {
    require ::npm

    exec { "${title}_npm_install":
        command     => '/usr/bin/npm update --no-bin-links',
        cwd         => $directory,
        user        => 'vagrant',
        environment => [
            "NPM_CONFIG_CACHE=${::npm::cache_dir}",
            'NPM_CONFIG_GLOBAL=false',
            'LINK=g++',
            'HOME=/home/vagrant',
        ],
        unless      => $unless,
    }

}
