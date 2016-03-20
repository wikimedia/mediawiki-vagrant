# == Define: npm::global
#
# Resource for installing node.js modules globally
#
define npm::global {
    require ::npm

    exec { "npm_global_${title}":
        command     => "/usr/bin/npm install -g ${title}",
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
