# == Class: role::antispoof
# Installs and sets up the AntiSpoof extension
class role::antispoof {
    require ::role::mediawiki

    mediawiki::extension { 'AntiSpoof':
        needs_update => true,
        composer     => true,
    }

    mediawiki::maintenance { 'populate_spoofuser':
        command     => '/usr/local/bin/foreachwikiwithextension AntiSpoof extensions/AntiSpoof/maintenance/batchAntiSpoof.php',
        refreshonly => true,
        require     => Mediawiki::Extension['AntiSpoof'],
        subscribe   => Exec['update_all_databases'],
    }
}
