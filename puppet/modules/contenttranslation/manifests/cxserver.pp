# == Class: contenttranslation::cxserver
#
# ContentTranslation is a tool for creating new articles in a
# target language from existing articles in a source language.
#
# This manifest installs the cxserver service.
#
# == Parameters
#
# [*port*]
#   The port the cxserver should listen on.
#   Defaults to 8090.
#
# [*dir*]
#   The directory in which to install cxserver.
#   Defaults to /srv/cxserver.
#
# [*apertium*]
#   The url for the apertium machine translation service.
#   Defaults to '//apertium.wmflabs.org'
#
# [*yandex_url*]
#   The url for the yandex machine translation service.
#   Defaults to 'https://translate.yandex.net'
#
# [*yandex_api_key*]
#   Api key for yandex translation service.
#   Defaults to 'null'.
#
# [*youdao_url*]
#   The url for the youdao machine translation service.
#   Defaults to 'https://fanyi.youdao.com/paidapi/fanyiapi'
#
# [*youdao_api_key*]
#   Api key for youdao translation service.
#   Defaults to 'null'.
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
    $port,
    $dir,
    $apertium,
    $yandex_url,
    $yandex_api_key,
    $youdao_url,
    $youdao_api_key,
    $registry = 'registry.yaml',
) {
    require ::service

    service::node { 'cxserver':
        port   => $port,
        script => 'server.js',
        module => 'app.js',
        config => template('contenttranslation/cxserver.config.yaml.erb'),
    }
}
