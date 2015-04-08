# == Class: mwv
#
# General settings for mediawiki-vagrant deployments
#
# === Parameters
#
# [*files_dir*]
#   Root directory for general file storage
#
# [*services_dir*]
#   Root directory for provisioning new services to use in the VM
#
# [*vendor_dir*]
#   Root directory for provisioning 3rd party services (eg Redis storage)
#
class mwv (
    $files_dir,
    $services_dir,
    $vendor_dir,
) {
    # FIXME: do we have initialization that can/should be moved here?
}
