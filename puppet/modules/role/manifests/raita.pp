# == Class: role::raita
#
# Raita is a dashboard built on Elasticsearch for visualizing and diagnosing
# browser test failures. The default URL for accessing the running dashboard
# will be http://raita.local.wmftest.net:8080/ though this may change
# according to your forwarded HTTP port or Hiera configuration.
#
# [*dir*]
#   Repository clone directory
#
# [*vhost_name*]
#   Apache virtual host name
#
class role::raita(
    $dir,
    $vhost_name,
) {
    include ::elasticsearch
    include ::apache::mod::headers
    include ::apache::mod::proxy
    include ::apache::mod::proxy_http

    require_package('nodejs')

    $index_url = 'http://127.0.0.1:9200/raita'
    $index = template('role/raita/index.json.erb')

    git::clone { 'integration/raita':
        directory => $dir,
        require   => Package['nodejs'],
    }

    exec { 'raita elasticsearch index':
        command => "/usr/bin/curl -X PUT '${index_url}/' -d '${index}'",
        unless  => "/usr/bin/curl -sf '${index_url}/_settings' 2> /dev/null",
        require => [
            Class['elasticsearch'],
            Git::Clone['integration/raita'],
        ],
    }

    exec { 'raita elasticsearch mappings':
        command => "/usr/bin/nodejs scripts/mappings.js import '${index_url}'",
        unless  => "/usr/bin/nodejs scripts/mappings.js check '${index_url}'",
        cwd     => $dir,
        require => Exec['raita elasticsearch index'],
    }

    file { '/tmp/raita-data.json':
        source => 'puppet:///modules/role/raita/data.json',
    }

    exec { 'raita import elasticsearch data':
        command   => "/usr/bin/curl -X POST '${index_url}/_bulk' --data-binary @/tmp/raita-data.json",
        onlyif    => "/usr/bin/curl -sf '${index_url}/_count' | /bin/grep -q '\"count\":0'",
        require   => Exec['raita elasticsearch mappings'],
        subscribe => File['/tmp/raita-data.json'],
    }

    apache::site { $vhost_name:
        content => template('role/raita/apache.conf.erb'),
    }
}
