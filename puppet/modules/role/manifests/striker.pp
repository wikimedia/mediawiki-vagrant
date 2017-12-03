# == Class: role::striker
# Provision Striker (Tool Labs Dashboard) and related testing environment.
#
# Installs Striker, a Phabricator instance, an LDAP auth wiki, and OAuth for
# the primary wiki. After provisioning some manual configuration steps are
# needed. See http://dev.wiki.local.wmftest.net:8080/wiki/VagrantRoleStriker
# for details.
#
# [*deploy_dir*]
#   Directory to clone git repos in.
#
# [*log_dir*]
#   Directory to write log files to. Directory must already exist.
#   A 'striker' subdirectory will be created.
#
# [*db_name*]
#   Logical MySQL database name (example: 'striker').
#
# [*db_user*]
#   MySQL user to use to connect to the database (example: 'striker').
#
# [*db_pass*]
#   Password for MySQL account (example: 'secret123').
#
# [*vhost_name*]
#   Apache vhost name. (example: 'striker.local.wmftest.net')
#
# [*oauth_consumer_key*]
#   OAuth consumer key.
#
# [*oauth_consumer_secret*]
#   OAuth consumer secret.
#
# [*phabricator_url*]
#   URL to Phabricator instance.
#
# [*phabricator_user*]
#   Phabricator API user.
#
# [*phabricator_token*]
#   Phabricator API user's access token.
#
# [*phabricator_repo_admin_group*]
#   PHID of git repository administrators group
#
# [*wikitech_url*]
#   URL to Wikitech instance.
#
# [*wikitech_consumer_key*]
#   OAuth consumer key
#
# [*wikitech_consumer_secret*]
#   OAuth consumer secret for Wikitech StrikerBot account
#
# [*wikitech_srv_secret_key*]
#   OAuth server-side secret key for Wikitech StrikerBot account
#
# [*wikitech_access_token*]
#   OAuth access token for Wikitech StrikerBot account
#
# [*wikitech_access_secret*]
#   OAuth access secret for Wikitech StrikerBot account
#
# [*wikitech_srv_access_secret*]
#   OAuth server-side access secret for Wikitech StrikerBot account
#
# [*use_xff*]
#   Use X-Forwared-For provided IP address for rate limiting
#
# [*xff_trusted_hosts*]
#   Upstream proxies to trust for X-Forwared-For data
#
class role::striker(
    $deploy_dir,
    $log_dir,
    $db_name,
    $db_user,
    $db_pass,
    $vhost_name,
    $oauth_consumer_key,
    $oauth_consumer_secret,
    $phabricator_url,
    $phabricator_user,
    $phabricator_token,
    $phabricator_repo_admin_group,
    $wikitech_url,
    $wikitech_consumer_key,
    $wikitech_consumer_secret,
    $wikitech_srv_secret_key,
    $wikitech_access_token,
    $wikitech_access_secret,
    $wikitech_srv_access_secret,
    $use_xff,
    $xff_trusted_hosts             = undef,
){
    include ::role::mediawiki
    include ::role::keystone
    include ::role::ldapauth
    include ::role::oathauth
    include ::role::oauth
    include ::role::syntaxhighlight
    include ::role::titleblacklist
    include ::apache::mod::wsgi_py3
    include ::memcached
    include ::mysql::large_prefix

    file { "${log_dir}/striker":
        ensure => 'directory',
        mode   => '0777',
    }

    # Setup Striker
    $app_dir = "${deploy_dir}/striker"
    git::clone { 'labs/striker':
        directory => $app_dir,
    }

    service::gitupdate { 'striker':
        dir          => $app_dir,
        restart      => true,
        service_name => 'apache2',
    }

    # Add packages needed for virtualenv built python modules
    $python = 'python3.4'
    require_package(
        'libffi-dev',
        'libldap2-dev',
        'default-libmysqlclient-dev',
        'libsasl2-dev',
        'libssl-dev',
        $python,
        "${python}-dev",
    )

    $venv = "${app_dir}/.venv"
    virtualenv::environment { $venv:
        owner  => $::share_owner,
        group  => $::share_group,
        python => $python,
    }
    virtualenv::package { 'striker':
        path          => $venv,
        package       => "-r ${app_dir}/requirements.txt",
        python_module => 'django',
    }

    # Configure striker
    file { '/etc/striker':
        ensure => 'directory',
        owner  => 'root',
        group  => 'root',
        mode   => '0555',
    }
    file { '/etc/striker/striker.ini':
        ensure  => 'present',
        owner   => 'root',
        group   => 'root',
        mode    => '0555',
        content => template('role/striker/striker.ini.erb'),
        require => [
            Git::Clone['labs/striker'],
            Class['::phabricator'],
            Class['::role::ldapauth'],
        ],
        notify  => Service['apache2'],
    }

    mysql::db { $db_name:
        ensure  => present,
        options => 'CHARACTER SET utf8mb4 COLLATE utf8mb4_bin',
    }
    mysql::user { $db_user:
        ensure   => present,
        grant    => "ALL ON ${db_name}.*",
        password => $db_pass,
        require  => Mysql::Db[$db_name],
    }

    # Hack needed because manage.py has trouble creating tables with large
    # column indices.
    # TODO: figure out how to fix the django migrations
    exec { 'striker initial tables':
      cwd         => '/vagrant/puppet/modules/role/files/striker',
      command     => "/usr/bin/mysql -u${db_user} -p${db_pass} ${db_name} < 20160916-01-initial.sql",
      refreshonly => true,
      before      => Exec['striker manage.py migrate'],
      require     => [
          Mysql::User[$db_user],
          Class['mysql::large_prefix'],
      ],
      subscribe   => Mysql::Db[$db_name],
    }

    exec { 'striker manage.py migrate':
        cwd     => $app_dir,
        command => "${venv}/bin/python manage.py migrate",
        require => [
            Mysql::User[$db_user],
            Class['mysql::large_prefix'],
            File['/etc/striker/striker.ini'],
        ],
        onlyif  => "${venv}/bin/python manage.py showmigrations --plan | /bin/grep -q '\\[ \\]'",
    }

    exec { 'striker manage.py collectstatic':
        cwd     => $app_dir,
        command => "${venv}/bin/python manage.py collectstatic --noinput",
        require => [
            Mysql::User[$db_user],
            File['/etc/striker/striker.ini'],
        ],
        unless  => "${venv}/bin/python manage.py collectstatic --noinput --dry-run| grep -q '^0 static'",
    }

    apache::site { $vhost_name:
        ensure   => present,
        # Load before MediaWiki wildcard vhost for Labs.
        priority => 40,
        content  => template('role/striker/apache.conf.erb'),
        require  => Class['apache::mod::wsgi_py3'],
        notify   => Service['apache2'],
    }

    # Setup devwiki
    $admin_email = 'admin@local.wmftest.net'
    mysql::sql { "USE ${::mediawiki::db_name}; UPDATE user SET user_email = '${admin_email}', user_email_authenticated = '20010115000000' WHERE user_name ='${::mediawiki::admin_user}'":
        unless  => "USE ${::mediawiki::db_name}; SELECT 1 FROM user WHERE user_name ='${::mediawiki::admin_user}' AND user_email_authenticated IS NOT NULL",
        require => Exec["${::mediawiki::db_name}_setup"],
    }

    # Setup Phabricator
    class { '::phabricator':
        remote => 'https://gerrit.wikimedia.org/r/phabricator/phabricator',
        branch => 'wmf/stable',
    }

    $ext_dir = "${deploy_dir}/phabricator-extensions"
    git::clone { 'phabricator-extensions':
        directory => $ext_dir,
        remote    => 'https://gerrit.wikimedia.org/r/p/phabricator/extensions',
        branch    => 'wmf/stable',
    }
    phabricator::config { 'load-libraries':
        value   => [$ext_dir],
        require => Git::Clone['phabricator-extensions'],
        before  => Exec['phab_setup_db'],
    }
    phabricator::config { 'darkconsole.enabled':
        value => true,
    }
    phabricator::config { 'auth.require-approval':
        value => false,
    }
    phabricator::config { 'config.ignore-issues':
        value => {
            'mysql.max_allowed_packet'                => true,
            'mysql.mode'                              => true,
            'mysql.innodb_buffer_pool_size'           => true,
            'mysql.ft_boolean_syntax'                 => true,
            'mysql.ft_min_word_len'                   => true,
            'mysql.ft_stopword_file'                  => true,
            'security.security.alternate-file-domain' => true
        }
    }
    phabricator::config { 'ui.header-color':
        value => 'red',
    }

    # Setup LDAP server
    exec { 'Add Striker LDAP data':
        command => template('role/striker/ldap_data.erb'),
        unless  => template('role/striker/ldap_check.erb'),
        require => Class['::role::ldapauth'],
        before  => Exec['bootstrap_keystone'],
    }

    exec { 'Add tools admin to openstack':
        command => '/usr/local/bin/use-openstack role add --user admin --project tools admin',
        user    => 'keystone',
        require => Exec['bootstrap_keystone'],
    }

    # Setup ldapauthwiki
    mediawiki::settings { 'ldapauth:oath-group':
        values => [
            '$wgGroupPermissions["oathauth"]["oathauth-api-all"] = true;',
        ]
    }
    mediawiki::user { 'StrikerBot':
        wiki     => 'ldapauthwiki',
        password => 'striker-vagrant',
        groups   => [
            'bot',
            'oathauth',
        ],
    }
    role::oauth::consumer { 'StrikerBot':
        user          => 'StrikerBot',
        description   => 'StrikerBot',
        owner_only    => true,
        consumer_key  => $wikitech_consumer_key,
        secret_key    => $wikitech_srv_secret_key,
        access_token  => $wikitech_access_token,
        access_secret => $wikitech_srv_access_secret,
        callback_url  => '/wiki/Special:OAuth/verified',
        grants        => [
            'useoauth',
            'highvolume',
            'editpage',
            'editprotected',
            'createeditmovepage',
            'rollback',
            'blockusers',
            'protect',
            'sendemail',
            'privateinfo',
            'oath',
        ],
        db_name       => 'ldapauthwiki',
    }

    # Add some documentation for developers
    mediawiki::import::text { 'VagrantRoleStriker':
        content => template('role/striker/VagrantRoleStriker.wiki.erb'),
    }

    mediawiki::import::text { 'MediaWiki:Titleblacklist':
        source  => 'puppet:///modules/role/striker/MediaWiki_Titleblacklist.wiki',
        db_name => 'ldapauthwiki',
        wiki    => 'ldapauth',
    }
}
