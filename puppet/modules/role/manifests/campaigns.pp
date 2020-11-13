# == Class: role::campaigns
# Provisions the Campaigns[https://www.mediawiki.org/wiki/Extension:Campaigns]
# extension, which allows tracking the source of account
# creations via a 'campaign' URL parameter.
#
class role::campaigns {
    include role::eventlogging

    mediawiki::extension { 'Campaigns': }
}

