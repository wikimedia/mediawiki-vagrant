# == Define: npm::global
#
# Resource for installing node.js modules globally
#
# === Parameters
#
# [*version*]
#   Specific package version to install
#
define npm::global (
    $version = undef,
) {
    require ::npm

    $package = $version ? {
        undef   => $title,
        default => "${title}@${version}",
    }

    exec { "npm_global_${title}":
        command     => "/usr/bin/npm install -g ${package}",
        user        => 'root',
        group       => 'root',
        creates     => "/usr/lib/node_modules/${title}",
        environment => [
            "NPM_CONFIG_CACHE=${::npm::cache_dir}",
            'NPM_CONFIG_GLOBAL=false',
            'LINK=g++',
        ],
    }
}
