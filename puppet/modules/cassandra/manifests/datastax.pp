# == Class: cassandra::datastax
#
# Add the datastax apt repo
#
# This is a bit of a hack to work around puppet dependency cycles that are
# created when apt::repository and require_package are used in the same
# manifest. That ends up making a circular dep on Exec['apt-get update'].
#
class cassandra::datastax {
    apt::repository { 'datastax':
        uri        => 'https://debian.datastax.com/community/',
        dist       => 'stable',
        components => 'main',
        keyfile    => 'puppet:///modules/cassandra/datastax-pubkey.asc',
        source     => false,
    }
}
