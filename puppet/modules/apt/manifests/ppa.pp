# == Define: apt::ppa
#
# A Personal Package Archive (PPA) is a special software repository for
# uploading source packages to be built and published as an APT
# repository by Launchpad. This Puppet resource type allows you to
# declare a PPA dependency for your system.
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
#  apt::ppa { 'chromium-daily/dev': }
#
define apt::ppa(
    $ensure = present,
    $ppa    = $title,
) {
    $safename = regsubst($name, '\W', '-', 'G')
    $listfile = "/etc/apt/sources.list.d/${safename}-${::lsbdistcodename}.list"

    if $ensure == 'absent' {
        # lint:ignore:80chars
        $command = "/usr/bin/add-apt-repository --yes --remove ppa:${ppa} && /usr/bin/apt-get update"
        # lint:endignore
        $onlyif  = "/usr/bin/test -e ${listfile}"
    } else {
        # lint:ignore:80chars
        $command = "/usr/bin/add-apt-repository --yes ppa:${ppa} && /usr/bin/apt-get update"
        # lint:endignore
        $onlyif  = "/usr/bin/test ! -e ${listfile}"
    }

    exec { $command:
        onlyif => $onlyif,
    }
}
