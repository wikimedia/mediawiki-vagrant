# == Define: nvm::install
#
# Install a specific version of Node
#
define nvm::install(
    $version = undef,
) {
    $use_version = $version ? {
        undef   => $::nvm::node_version,
        default => $version,
    }

    exec { "${title}_nvm_install":
        command     => "/bin/bash -c 'source ${::nvm::nvm_dir}/nvm.sh && nvm install ${use_version}'",
        user        => 'root',
        environment => ["NVM_DIR=${::nvm::nvm_dir}", 'HOME=/root'],
        require     => [Exec['download_nvm']],
    }
}
