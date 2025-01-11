# == Define: npm::install
#
# Custom resource for installing node.js module dependencies
#
# === Parameters
#
# [*directory*]
#   Name of the directory where to execute the install command
#
# [*environment*]
#   Extra environment variables to set when running npm install
#
# [*node_version*]
#   The Node version to use. Default: '12'
define npm::install(
    $directory,
    $environment = [],
    $node_version = '12',
) {
    require ::npm

    $nvm_dir = $::nvm::nvm_dir
    $use_version = $node_version ? {
        undef   => $::nvm::node_version,
        default => $node_version,
    }

    exec { "${title}_npm_install":
        command     => "/bin/bash -c 'source ${nvm_dir}/nvm.sh && nvm use ${use_version} && npm install --no-bin-links'",#
        user        => 'vagrant',
        cwd         => $directory,
        environment => [
            "NVM_DIR=${nvm_dir}",
            "NPM_CONFIG_CACHE=${::npm::cache_dir}",
            'NPM_CONFIG_GLOBAL=false',
            'LINK=g++',
            'HOME=/home/vagrant',
        ] + $environment,
        creates     => "${directory}/node_modules",
        logoutput   => true,
    }
}
