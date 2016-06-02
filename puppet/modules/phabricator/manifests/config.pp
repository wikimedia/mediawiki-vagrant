# vim:set sw=4 ts=4 sts=4 et:

# == Class: phabricator::config
#
# This class sets a phabricator config value
#
# === Parameters
#
# [*value*]
#   Configuration value
#
define phabricator::config(
    $value,
){
    include ::phabricator

    $phab_dir = "${::phabricator::deploy_dir}/phabricator"
    # Get the value as a json string
    $json_value = ordered_json($value)
    # Strip leading/trailing quotes (if $value is a plain string don't
    # quote it because that will make `config set` sad)
    $arg_value = inline_template('<%= @json_value.gsub(/^"|"$/, "").to_s %>')
    # This still has one annyoing edge case: Phab's internal metadata
    # classifies mysql.port as a string rather than an integer for unknown
    # reasons. The jq check will fail on this every time since ordered_json()
    # will output a number and the local.json version it is compared against
    # is a quoted string.
    exec { "phab_set_${title}":
        command => "${phab_dir}/bin/config set ${title} '${arg_value}'",
        unless  => "/usr/bin/jq '.[\"${title}\"] == ${json_value}' ${phab_dir}/conf/local/local.json | /bin/grep -q true",
        require => [
            Git::Clone['phabricator'],
            Package['jq'],
        ],
        before  => Service['phd'],
    }
}
