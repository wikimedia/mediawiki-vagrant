# == Class: role::labs_initial_wiki
#
#  For labs:  loads a ready-made logo and privacy policy into the
#  initial wiki.
#
class role::labs_initial_content {
    mediawiki::import_dump { 'labs_privacy':
        require            => Class['::role::mediawiki'],
        xml_dump           => '/vagrant/puppet/modules/labs/files/labs_privacy_policy.xml',
        dump_sentinel_page => 'Testwiki:Privacy_policy',
    }

    file { '/var/www/labs_mediawiki_logo.png':
        require  => Class['::role::mediawiki'],
        ensure   => present,
        source   => '/vagrant/puppet/modules/labs/files/labs_vagrant_logo.png'
    }

    file { '/var/www/robots.txt':
        require  => Class['::role::mediawiki'],
        ensure   => present,
        source   => '/vagrant/puppet/modules/labs/files/robots.txt'
    }

    mediawiki::settings { 'labs-vagrant logo':
        values => {
            wgLogo          => '/labs_mediawiki_logo.png',
            wgMetaNamespace => 'Testwiki',
        },
    }

}
