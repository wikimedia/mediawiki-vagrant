# == Class: apt::wikimedia_experimental
#
# Import the experimental component of apt.wikimedia.org
#
class apt::wikimedia_experimental {
    apt::repository { 'wikimedia-experimental':
        uri        => 'https://apt.wikimedia.org/wikimedia',
        dist       => "${::lsbdistcodename}-wikimedia",
        components => 'experimental',
    }
}
