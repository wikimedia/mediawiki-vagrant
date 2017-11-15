# == Class: role::ores_service
# This role installs the [ORES][https://ores.wikimedia.org/] service.
#
class role::ores_service {
    include ::ores

    $ores_hostname = $::ores::vhost_name

    # when role::ores is also enabled, make it use the local service
    mediawiki::settings { 'ORES service':
        values   => {
            wgOresBaseUrl           => "http://localhost:${::ores::port}/",
            wgOresWikiId            => 'wiki',
            wgOresModels            => {
                damaging  => true,
                goodfaith => false,
                reverted  => false,
                wp10      => false,
            },
            # Use calculated thresholds.
            wgOresFiltersThresholds => {
                damaging => {
                    likelygood => {
                        min => 0,
                        max => 'recall_at_precision(min_precision=0.99)',
                    },
                    maybebad   => {
                        min => 'recall_at_precision(min_precision=0.15)',
                        max => 1,
                    },
                    likelybad  => {
                        min => 'recall_at_precision(min_precision=0.45)',
                        max => 1,
                    },
                    # verylikelybad uses default
                },
            },
        },
        priority => 20,
    }

    mediawiki::import::text { 'VagrantRoleOresService':
        content => template('role/ores_service/VagrantRoleOresService.wiki.erb'),
    }
}
