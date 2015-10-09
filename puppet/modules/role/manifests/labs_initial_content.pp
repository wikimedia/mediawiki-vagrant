# == Class: role::labs_initial_content
#
#  For labs:  loads a ready-made logo and privacy policy into the
#  initial wiki.
#
class role::labs_initial_content {
    require mediawiki::apache

    mediawiki::import::dump { 'labs_privacy':
        xml_dump           => '/vagrant/puppet/modules/labs/files/labs_privacy_policy.xml',
        dump_sentinel_page => 'Testwiki:Privacy_policy',
    }

    file { "${::mediawiki::apache::docroot}/labs_mediawiki_logo.png":
        ensure => present,
        source => 'puppet:///modules/labs/labs_vagrant_logo.png',
    }

    mediawiki::settings { 'labs-vagrant logo':
        values => {
            wgLogo          => '/labs_mediawiki_logo.png',
            wgMetaNamespace => 'Testwiki',
        },
    }

}
