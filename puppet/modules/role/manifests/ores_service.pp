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
            # the mock scorer used by the local service cannot
            # provide recall stats so dynamic threshold configuration
            # would cause score fetches to silently fail. Use a
            # constant dummy configuration instead.
            wgOresFiltersThresholds => {
                damaging => {
                    likelygood    => {
                        min => 0,
                        max => 0.3,
                    },
                    maybebad      => {
                        min => 0.2,
                        max => 1,
                    },
                    likelybad     => {
                        min => 0.5,
                        max => 1,
                    },
                    verylikelybad => {
                        min => 0.8,
                        max => 1,
                    },
                },
            },
        },
        priority => 20,
    }

    mediawiki::import::text { 'VagrantRoleOresService':
        content => template('role/ores_service/VagrantRoleOresService.wiki.erb'),
    }
}
