# == Define: php::ini
#
# This resource type represents a set of PHP configuration directives
# that are managed via an ini file in /etc/php5/conf.d. PHP interprets
# these files as extensions of the main php.ini configuration file. For
# more information, see <http://wiki.debian.org/PHP#Configuration_layout>
# and <http://php.net/manual/en/configuration.file.php>.
#
# === Parameters
#
# [*settings*]
#   A hash or array of PHP configuration directives. For a list of core
#   php.ini directives, see <http://www.php.net/manual/en/ini.php>.
#
# [*ensure*]
#   If 'present', generates the configuration file; if 'absent', removes
#   the file. Default: 'present'.
#
# === Examples
#
# Example showing settings as a hash:
#
#   php::ini { 'apc':
#     settings => {
#       'apc.enabled'          => 1,
#       'apc.cache_by_default' => 1
#     },
#  }
#
# Example showing settings as an array:
#
#   php::ini { 'apc':
#     settings => [
#      'apc.enabled = 1',
#      'apc.cache_by_default = 1'
#     ],
#  }

#
define php::ini (
    $settings,
    $ensure = present,
) {
    include ::php
    include ::apache

    $basename = inline_template('<%= @title.gsub(/\W/, "-").downcase %>')

    if versioncmp($::lsbdistrelease, '14') > 0 {
        $conffile = "/etc/php5/mods-available/${basename}.ini"
    } else {
        $conffile = "/etc/php5/conf.d/${basename}.ini"
    }

    file { $conffile:
        ensure  => $ensure,
        content => template('php/conffile.ini.erb'),
        require => Package['php5'],
        notify  => Service['apache2'],
    }

    if $ensure == present {
        exec { "/usr/sbin/php5enmod -s ALL ${basename}":
            refreshonly => true,
            onlyif      => 'test -x /usr/sbin/php5enmod',
            subscribe   => File[$conffile],
        }
    } else {
        exec { "/usr/sbin/php5dismod -s ALL ${basename}":
            refreshonly => true,
            onlyif      => 'test -x /usr/sbin/php5dismod',
            before      => File[$conffile],
        }
    }
}
