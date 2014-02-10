# == Class: role::fundraising
# This role configures MediaWiki to use the 'fundraising/1.22' branch
# and sets up the ContributionTracking, FundraisingEmailUnsubscribe, and
# DonationInterface extensions.
class role::fundraising {
    include role::mediawiki
    include packages::rsyslog

    $rsyslog_max_message_size = '64k'

    service { 'rsyslog':
        ensure     => running,
        provider   => 'init',
        require    => Package['rsyslog'],
        hasrestart => true,
    }

    file { '/etc/rsyslog.d/60-payments.conf':
        content => template('fr-payments-rsyslog.conf.erb'),
        require => Package['rsyslog'],
        notify  => Service['rsyslog'],
    }

    exec { 'checkout fundraising branch':
        command => 'git checkout --track origin/fundraising/1.22',
        unless  => 'git branch --list | grep -q fundraising/1.22',
        cwd     => $mediawiki::dir,
        require => Exec['mediawiki setup'],
    }

    mediawiki::extension { [ 'ContributionTracking', 'ParserFunctions' ]: }

    mediawiki::extension { 'FundraisingEmailUnsubscribe':
        entrypoint => 'FundraiserUnsubscribe.php',
    }

    mediawiki::extension { 'DonationInterface':
        entrypoint   => 'donationinterface.php',
        settings     => template('fr-config.php.erb'),
        needs_update => true,
        require      => [
            File['/etc/rsyslog.d/60-payments.conf'],
            Exec['checkout fundraising branch'],
            Mediawiki::Extension[
                'ContributionTracking',
                'FundraisingEmailUnsubscribe',
                'ParserFunctions'
            ],
        ],
    }
}
