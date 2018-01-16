# == Class: role::ldapauth
# Provisions and LDAP server and the LdapAuthentication extension for use by
# a wiki named ldapauth.wiki.local.wmftest.net.
#
# === Parameters
# [*proxy_agent_password*]
#   Password for proxy agent account
#
# [*writer_password*]
#   Password for account with write access
#
# [*admin_password*]
#   Password for LDAP admin account
#
class role::ldapauth(
    $proxy_agent_password,
    $writer_password,
    $admin_password,
) {
    require_package('php-ldap')

    # This is a lazy short cut so we don't have to pass a bazillion options to
    # create the initial LDIF data.
    $base_dn = 'dc=wmftest,dc=net'
    $admin_dn = "cn=admin,${base_dn}"
    $user_base_dn = "ou=People,${base_dn}"
    $proxy_agent_dn = "cn=proxyagent,${base_dn}"
    $writer_dn = "cn=writer,${base_dn}"

    class { '::openldap':
        suffix         => $base_dn,
        datadir        => '/var/lib/ldap',
        admin_dn       => $admin_dn,
        admin_password => $admin_password,
    }

    exec { 'Create LDAP db':
        command => template('role/ldapauth/create_db.erb'),
        unless  => template('role/ldapauth/check_db.erb'),
        require => Class['::openldap'],
    }

    mediawiki::wiki { 'ldapauth':
        wgconf => {
            'wmvExtensions' => {
                  'CentralAuth' => false,
            },
        },
    }

    mediawiki::extension { 'LdapAuthentication':
        needs_update => true,
        settings     => template('role/ldapauth/LdapAuthentication.php.erb'),
        wiki         => 'ldapauth',
    }
}
