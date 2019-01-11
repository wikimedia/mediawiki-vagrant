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
    $uwsgi_port,
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
    include ::apache::mod::alias
    include ::apache::mod::proxy_balancer
    include ::apache::mod::proxy_http
    include ::apache::mod::rewrite
    include ::memcached
    include ::mysql::large_prefix

    # Add packages needed for virtualenv built python modules
    $python = 'python3'
    require_package(
        'libffi-dev',
        'libldap2-dev',
        'libmariadbclient-dev',
        'libsasl2-dev',
        'libssl-dev',
        $python,
        "${python}-dev",
    )

    $app_dir = "${::service::root_dir}/striker"
    $venv = "${app_dir}/.venv"

    service::uwsgi { 'striker':
        port       => $uwsgi_port,
        config     => {
            need-plugins  => 'python3, logfile',
            chdir         => "${deploy_dir}/striker",
            venv          => $venv,
            wsgi          => 'striker.wsgi',
            vacuum        => true,
            http-socket   => "127.0.0.1:${uwsgi_port}",
            py-autoreload => 2,
            env           => [
                'LANG=C.UTF-8',
                'PYTHONENCODING=utf-8',
            ],
            req-logger    => "file:${log_dir}/access.log",
            log-format    => '%(addr) - %(user) [%(ltime)] "%(method) %(uri) (proto)" %(status) %(size) "%(referer)" "%(uagent)" %(micros)',
        },
        git_remote => sprintf($::git::urlformat, 'labs/striker'),
    }

    virtualenv::environment { $venv:
        owner   => $::share_owner,
        group   => $::share_group,
        python  => $python,
        require => Git::Clone['striker'],
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
            Virtualenv::Package['striker'],
            Class['::phabricator'],
            Class['::role::ldapauth'],
        ],
        notify  => Service['uwsgi-striker'],
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

    $populate_unless = "use ${db_name};select count(*) from tools_softwarelicense"
    exec { 'striker populate software_license':
        cwd     => $app_dir,
        command => "${venv}/bin/python manage.py loaddata software_license.json",
        require => [
            Exec['striker manage.py migrate'],
        ],
        unless  => "/usr/bin/mysql -qfsANe \"${populate_unless}\" | /usr/bin/tail -1 | /bin/grep -vq 0",
    }

    apache::site { $vhost_name:
        ensure   => present,
        # Load before MediaWiki wildcard vhost for Labs.
        priority => 40,
        content  => template('role/striker/apache.conf.erb'),
        notify   => Service['apache2'],
    }

    # Setup Phabricator
    class { '::phabricator':
        remote => 'https://phabricator.wikimedia.org/source/phabricator.git',
        branch => 'wmf/stable',
    }

    $ext_dir = "${deploy_dir}/phabricator-extensions"
    git::clone { 'phabricator-extensions':
        directory => $ext_dir,
        remote    => 'https://phabricator.wikimedia.org/source/phab-extensions.git',
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
        value => [
            'mysql.max_allowed_packet',
            'mysql.mode',
            'mysql.innodb_buffer_pool_size',
            'mysql.ft_boolean_syntax',
            'mysql.ft_min_word_len',
            'mysql.ft_stopword_file',
            'security.security.alternate-file-domain',
        ]
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
        unless  => '/usr/local/bin/use-openstack role assignment list --user admin --project tools --names | grep admin',
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
