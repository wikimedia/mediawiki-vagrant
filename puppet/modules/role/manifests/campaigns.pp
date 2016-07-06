# == Class: role::campaigns
# Provisions the Campaigns[1] extension, which allows tracking the source
# of account creations via a 'campaign' URL parameter.
#
# [1] https://www.mediawiki.org/wiki/Extension:Campaigns
#
class role::campaigns {
    include role::eventlogging

    mediawiki::extension { 'Campaigns': }
}

