# == Class: nvm
#
# Install and configure NVM
#
class nvm (
    $nvm_version = 'v0.40.1',
    $node_version = '12'
) {
    $nvm_dir = '/usr/local/nvm'

    file { $nvm_dir:
        ensure => 'directory',
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
        before => Exec['download_nvm'],
    }

    exec { 'download_nvm':
        command     => "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${nvm_version}/install.sh | PROFILE=/dev/null bash",
        creates     => "${nvm_dir}/nvm.sh",
        require     => Package['curl'],
        user        => 'root',
        environment => ["NVM_DIR=${nvm_dir}"],
    }

    nvm::install { "install_node_${node_version}":
        version => $node_version,
    }
}
