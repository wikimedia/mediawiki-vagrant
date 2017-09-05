# == Class: ocg::service
# Internal helper for the ocg class, do not use elsewhere.
# Used to set up the four OCG-related Node.js services.
#
# === Parameters
#
# [*service*]
#   Service name
#
# [*hash*]
#   Hash of service name => gerrit URL suffix
#

define ocg::service (
    $service = $title,
    $hash = undef,
) {
    $remote_suffix = $hash[$service]
    git::clone { $service:
        directory => "${::service::root_dir}/${service}",
        remote    => "https://gerrit.wikimedia.org/r/p/mediawiki/extensions/Collection/OfflineContentGenerator${remote_suffix}",
    }
    npm::install { "${::service::root_dir}/${service}":
        directory => "${::service::root_dir}/${service}",
        require   => Git::Clone[$service],
    }
    service::gitupdate { $service:
        type    => 'nodejs',
        update  => true,
        restart => $service == 'mw-ocg-service',
    }
}

