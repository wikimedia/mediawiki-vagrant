# == Class: role::statsd
# Installs a Statsd instance which collects statistics from your wiki
# The statsd output goes to /vagrant/logs/statsd.log
#
class role::statsd (
) {
    include ::statsd

    mediawiki::settings { 'Statsd':
        values => {
            wgStatsdServer => "localhost:${::statsd::port}",
        },
    }
}
