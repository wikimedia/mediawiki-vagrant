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
    $silverpop_db_name,
    $silverpop_db_user,
    $silverpop_db_pass,
) {
    $audit_base = '/var/spool/audit'

    require_package(
        'default-libmysqlclient-dev',
        'libyaml-dev',
        'libffi-dev',
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

    mysql::user { $silverpop_db_user:
      ensure   => present,
      grant    => 'ALL ON *.*',
      password => $silverpop_db_pass,
      require  => Mysql::Db[$silverpop_db_name],
    }

    mysql::db { $silverpop_db_name: }

    exec { 'create_silverpop_reference_data':
        command => "/usr/bin/mysql -u${silverpop_db_user} -p${silverpop_db_pass} '${silverpop_db_name}' < ${dir}/silverpop_export/silverpop_countrylangs.sql",
        unless  => "/usr/bin/mysql -u${silverpop_db_user} -p${silverpop_db_pass} '${silverpop_db_name}' -e 'select 1 from silverpop_countrylangs'",
        require => [
            Git::Clone['wikimedia/fundraising/tools'],
            Mysql::Db[$silverpop_db_name],
            Mysql::User[$silverpop_db_user]
        ],
    }

    exec { 'frtools_python_requirements':
        command => "pip install --upgrade setuptools; pip install -r ${dir}/requirements.txt",
        require => [
            Git::Clone['wikimedia/fundraising/tools'],
            Package['default-libmysqlclient-dev'],
            Package['libyaml-dev'],
            Package['libffi-dev'],
        ],
    }
}
