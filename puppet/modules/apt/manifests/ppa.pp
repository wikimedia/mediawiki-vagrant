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
    # Provides add-apt-repository
    require_package('software-properties-common')

    $safename = regsubst($name, '\W', '-', 'G')
    $listfile = "/etc/apt/sources.list.d/${safename}-${::lsbdistcodename}.list"

    if $ensure == 'absent' {
        $command = "/usr/bin/add-apt-repository --yes --remove ppa:${ppa} && /usr/bin/apt-get update"
        $onlyif  = "/usr/bin/test -e ${listfile}"
    } else {
        # PPA's are for Ubuntu, not Debian but may work if we hack the distro
        # name to be a modern Ubuntu LTS instead of stretch.
        $command = "/usr/bin/add-apt-repository --yes ppa:${ppa} && /bin/sed -i 's/${::lsbdistcodename}/xenial/g' ${listfile} && /usr/bin/apt-get update"
        $onlyif  = "/usr/bin/test ! -e ${listfile}"
    }

    exec { $command:
        onlyif  => $onlyif,
        require => Package['software-properties-common'],
    }
}
