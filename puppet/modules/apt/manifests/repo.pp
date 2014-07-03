# == Define: apt::repo
#
# A basic define for including new repositories based
# on a template and a given key.
#
# === Parameters
#
# [*ensure*]
#   If 'present', adds the PPA; if 'absent', removes it.
#   Default: 'present'.
#
# [*ppa*]
#   Name of the PPA to configure. Defaults to the resource title.
#
# === Examples
#
#  apt::repo { 'hhvm': '1BE7A449' }
#
define apt::repo(
    $keyid,
    $ensure   = present,
    $key      = "apt/${title}.key",
    $template = "apt/${title}.list.erb"
) {
    $safename = regsubst($name, '\W', '-', 'G')

    if $ensure == present {
        file { "/tmp/${title}.key":
            ensure => present,
            source => "puppet:///modules/${key}",
        }

        exec { "add ${title} apt key":
            command => "apt-key add /tmp/${title}.key",
            require => File["/tmp/${title}.key"],
            before  => File["/etc/apt/sources.list.d/${safename}.list"],
            unless  => "apt-key list | grep -q ${keyid}",
        }

        file { "/etc/apt/sources.list.d/${safename}.list":
            content => template($template),
            notify  => Exec['apt-get update'],
        }
    } else {
        exec { "remove ${title} apt key":
            command => "apt-key del ${keyid}",
            onlyif  => "apt-key list | grep -q ${keyid}",
            before  => File["/etc/apt/sources.list.d/${safename}.list"],
        }

        file { "/etc/apt/sources.list.d/${safename}.list":
            ensure => absent,
            notify => Exec['apt-get update'],
        }
    }
}
