# == Class: contenttranslation::cxserver
#
# ContentTranslation is a tool for creating new articles in a
# target language from existing articles in a source language.
#
# This manifest installs the cxserver service.
#
# == Parameters
#
# [*dir*]
#   The directory in which to install cxserver.
#   Defaults to /srv/cxserver.
#
# [*port*]
#   The port the cxserver should listen on.
#   Defaults to 8090.
#
# [*proxy*]
#   Forward proxy to use when connecting to machine translation services.
#   Defaults to 'null' for no proxy.
#
# [*log*]
#   Log directory.
#   Defaults to 'log'.
#
# [*allow_cors*]
#   Hosts for CORS. Defaults to '*'.
#
# [*apertium*]
#   The url for the apertium machine translation service.
#   Defaults to '//apertium.wmflabs.org'
#
# [*yandex*]
#   The url for the yandex machine translation service.
#   Defaults to 'https://translate.yandex.net'
#
# [*yandex_key*]
#   Api key for yandex translation service.
#   Defaults to 'null'.
#
# [*youdao*]
#   The url for the youdao machine translation service.
#   Defaults to 'https://fanyi.youdao.com/paidapi/fanyiapi'
#
# [*youdao_key*]
#   Api key for youdao translation service.
#   Defaults to 'null'.
#
# [*secure*]
#   Whether or not to run cxserver on https.
#   Defaults to 'false'.
#
# [*ssl_key*]
#   Path to ssl key file.
#   Defaults to 'null'.
#
# [*cert*]
#   Path to cert file.
#   Defaults to 'null'.
#
# [*workers*]
#   Number of workers to spawn when starting cxserver.
#   Defaults to 2.
#
# == Example
#
#  class { 'contenttranslation::cxserver':
#    port => 8090,
#  }
#
# == Customization
#
#   Default values are defined in /vagrant/puppet/hieradata/common.yaml
#   To customize create a file called 'local.yaml' in the same location
#   and include entries for the settings you want to override.
#
class contenttranslation::cxserver(
    $dir,
    $port,
    $proxy,
    $log,
    $allow_cors,
    $apertium,
    $yandex,
    $yandex_key,
    $youdao,
    $youdao_key,
    $secure,
    $ssl_key,
    $cert,
    $workers,
) {
    require ::npm

    git::clone { 'mediawiki/services/cxserver/deploy':
        directory => $dir,
        owner     => $::share_owner,
        group     => $::share_group,
    }

    file { "${dir}/src/config.yaml":
        content => template('contenttranslation/cxserver.config.yaml.erb'),
        require => Git::Clone['mediawiki/services/cxserver/deploy'],
    }

    file { '/etc/init/cxserver.conf':
        content => template('contenttranslation/cxserver.conf.erb'),
    }

    service { 'cxserver':
        ensure    => running,
        provider  => 'upstart',
        subscribe => [
            File['/etc/init/cxserver.conf'],
            File["${dir}/src/config.yaml"],
        ],
    }
}
