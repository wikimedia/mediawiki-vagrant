# == Class: role::antispoof
# Installs and sets up the AntiSpoof extension
class role::antispoof {
    include role::mediawiki

    mediawiki::extension { 'AntiSpoof':
        needs_update => true,
    }

    exec { 'populate spoofuser':
        command     => "php5 ${::role::mediawiki::dir}/extensions/AntiSpoof/maintenance/batchAntiSpoof.php",
        refreshonly => true,
        user        => 'www-data',
        require     => Mediawiki::Extension['AntiSpoof'],
        subscribe   => Exec['update database'],
    }
}
