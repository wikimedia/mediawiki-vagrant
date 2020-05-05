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
    file { "${::mediawiki::apache::docroot}/labs_mediawiki_logo-1.5x.png":
        ensure => present,
        source => 'puppet:///modules/labs/labs_vagrant_logo-1.5x.png',
    }
    file { "${::mediawiki::apache::docroot}/labs_mediawiki_logo-2x.png":
        ensure => present,
        source => 'puppet:///modules/labs/labs_vagrant_logo-2x.png',
    }

    mediawiki::settings { 'labs-vagrant logo':
        values => {
            wgLogos         => {
                '1x'   => '/labs_mediawiki_logo.png',
                '1.5x' => '/labs_mediawiki_logo-1.5x.png',
                '2x'   => '/labs_mediawiki_logo-2x.png',
            },
            wgMetaNamespace => 'Testwiki',
        },
    }

}
