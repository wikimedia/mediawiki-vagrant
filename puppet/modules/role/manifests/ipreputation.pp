# == Class: role::ipreputation
# Provisions the IPReputation[https://www.mediawiki.org/wiki/Extension:IPReputation]
# extension, which provides access for fetching, logging, and acting on IP reputation data.
#
# It does not install the IPoid service IPReputation depends on; as such, it is only useful
# for testing. Lookups will always return "no data".
#
class role::ipreputation {
  mediawiki::extension { 'IPReputation':
  }
}

