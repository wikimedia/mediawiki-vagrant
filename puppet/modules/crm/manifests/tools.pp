# == Class: crm::tools
#
# Miscellaneous tools written in Python.
#
# === Parameters
#
# [*dir*]
#   Installation directory.
#
class crm::tools(
    $dir,
) {
    $db_url = "mysql://${::crm::db_user}:${::crm::db_pass}@localhost/${::crm::drupal_db}"

    $audit_base = '/var/spool/audit'

    require_package(
        'libmysqlclient-dev',
        'libyaml-dev',
        'libffi-dev'
    )

    git::clone { 'wikimedia/fundraising/tools':
        directory => $dir,
    }

    file { '/etc/fundraising':
        ensure => 'directory',
        mode   => '0755',
    }

    file { '/etc/fundraising/silverpop_export.yaml':
        ensure  => 'file',
        content => template('crm/silverpop_export.yaml.erb'),
        mode    => '0644',
        require => File['/etc/fundraising'],
    }

    mysql::db { 'silverpop': }

    exec { 'create_silverpop_reference_data':
        command => "/usr/bin/mysql -u '${::crm::db_user}' -p'${::crm::db_pass}' 'silverpop' < ${dir}/silverpop_export/silverpop_countrylangs.sql",
        unless  => "/usr/bin/mysql -u '${::crm::db_user}' -p'${::crm::db_pass}' 'silverpop' -e 'select 1 from silverpop_countrylangs'",
        require => [
            Git::Clone['wikimedia/fundraising/tools'],
            Mysql::Db['silverpop'],
        ],
    }

    exec { 'frtools_python_requirements':
        command => "pip install --upgrade setuptools; pip install -r ${dir}/requirements.txt",
        require => [
            Git::Clone['wikimedia/fundraising/tools'],
            Package['libmysqlclient-dev'],
            Package['libyaml-dev'],
            Package['libffi-dev'],
        ],
    }
}
