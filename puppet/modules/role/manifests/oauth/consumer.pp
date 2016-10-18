# == Define: role::oauth::consumer
# Provision an OAuth consumer directly in the database.
#
# == Parameters:
# [*consumer_key*]
#   OAuth consumer key.
# [*secret_key*]
#   OAuth secret key.
# [*callback_url*]
#   Application callback url.
# [*is_prefix*]
#   Allow consumer to specify a callback in requests and use callback_url as
#   a required prefix? Default true.
# [*description*]
#   Application description. Default $title.
# [*wiki*]
#   Project that grant is authorized for. Default '*'.
# [*grants*]
#   Array of grants to allow authenticated clients. Default ['authonly'].
# [*restrictions*]
#   Hash of usage restrictions. Default {'IPAddresses' => ['0.0.0.0/0','::/0']}.
# [*user*]
#   Grant owner. Default 'Admin'.
# [*owner_only*]
#   Consumer is for use by the owner only? Default false.
# [*access_token*]
#   Accepted token for owner-only grant. Default undef.
# [*access_secret*]
#   Accepted secret for owner-only grant. Default undef.
define role::oauth::consumer (
    $consumer_key,
    $secret_key,
    $callback_url,
    $is_prefix     = true,
    $description   = $title,
    $wiki          = '*',
    $grants        = ['authonly'],
    $restrictions  = {'IPAddresses' => ['0.0.0.0/0','::/0']},
    $user          = 'Admin',
    $owner_only    = false,
    $access_token  = undef,
    $access_secret = undef,
    $db_name       = $::mediawiki::db_name,
) {
    include ::role::oauth

    $grants_json = ordered_json($grants)
    $restrictions_json = ordered_json($restrictions)

    mysql::sql { "Register OAuth ${title}":
        sql     => template('role/oauth/register.sql.erb'),
        unless  => template('role/oauth/check.sql.erb'),
        require => [
            Mediawiki::Extension['OAuth'],
            Exec['update_all_databases'],
        ]
    }

    if $owner_only {
        mysql::sql { "Authorize OAuth ${title}":
            sql     => template('role/oauth/authorize.sql.erb'),
            unless  => template('role/oauth/check-auth.sql.erb'),
            require => Mysql::Sql["Register OAuth ${title}"],
        }
    }
}
