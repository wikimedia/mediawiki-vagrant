# == Define: npm::install
#
# Custom resource for installing node.js module dependencies
#
# === Parameters
#
# [*directory*]
#   Name of the directory where to execute the install command
#
define npm::install(
    $directory,
) {
    require ::npm

    exec { "${title}_npm_install":
        command     => '/usr/bin/npm install --no-bin-links',
        cwd         => $directory,
        user        => 'vagrant',
        environment => [
            "NPM_CONFIG_CACHE=${::npm::cache_dir}",
            'NPM_CONFIG_GLOBAL=false',
            'LINK=g++',
            'HOME=/home/vagrant',
        ],
        creates     => "${directory}/node_modules",
        logoutput   => true,
    }
}
