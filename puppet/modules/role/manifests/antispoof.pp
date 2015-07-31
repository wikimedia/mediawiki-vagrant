# == Class: role::antispoof
# Installs and sets up the AntiSpoof extension
class role::antispoof {
    require ::role::mediawiki

    mediawiki::extension { 'AntiSpoof':
        needs_update => true,
    }

    exec { 'populate_spoofuser':
        # lint:ignore:80chars
        command     => "/usr/local/bin/foreachwiki ${::mediawiki::dir}/extensions/AntiSpoof/maintenance/batchAntiSpoof.php",
        # lint:endignore
        refreshonly => true,
        user        => 'www-data',
        require     => Mediawiki::Extension['AntiSpoof'],
        subscribe   => Exec['update_all_databases'],
    }
}
