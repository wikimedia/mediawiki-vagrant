# == Class: Kafka::Repository
#
# Configure an apt repository to fetch confluent packages from.
class kafka::repository {
    apt::repository { 'thirdparty-confluent':
        uri        => 'http://apt.wikimedia.org/wikimedia',
        dist       => "${::lsbdistcodename}-wikimedia",
        components => 'thirdparty/confluent',
    }
}
