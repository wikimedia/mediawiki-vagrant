# == Define: mediawiki::user
#
# Uses MediaWiki's maintenance scripts to create a MediaWiki account and/or
# add groups for an account
#
# === Parameters
#
# [*password*]
#   Password for the new account.
#
# [*username*]
#   User name of account to create or modify. Defaults to the resource title.
#
# [*email*]
#   Email address for the new account.
#
# [*wiki*]
#   DB name of Wiki that account will be on. Defaults to the primary wiki.
#
# [*groups*]
#   Array of groups to add.  Defaults to no new groups.
#   This does *not* support removing groups from a user.
#
# === Examples
#
#  Make sure the 'sumana' user exists
#
#  mediawiki::user { 'sumana':
#     password => 'secretpassword',
#  }
#
#  Make sure the AdminSuppresser user exists and has the 'sysop' and
#  'suppress' groups.
#
#  mediawiki::user { 'AdminSuppresser':
#     password   => 'securepassword',
#     groups     => ['sysop', 'suppress']
#  }
#
define mediawiki::user(
    $password,
    $username = $title,
    $email    = undef,
    $wiki     = $::mediawiki::db_name,
    $groups   = [],
) {
    include ::mediawiki

    # Ideally, this would use the same canonicalization as core.
    # In the meantime, just address one common issue.

    # Capitalize first character
    # Ruby's capitalize has a bug/feature where it *lower-cases* every
    # character except the first even when they were already
    # capitalized.  Puppet inherits this.
    $canonical_username = inline_template('<%= @username[0].capitalize + @username[1..-1] %>')

    mediawiki::maintenance { "mediawiki_user_${canonical_username}_${wiki}":
        command => "/usr/local/bin/mwscript createAndPromote.php \
                    --wiki='${wiki}' '${canonical_username}' '${password}'",
        unless  => "/usr/local/bin/mwscript createAndPromote.php \
                    --wiki='${wiki}' '${canonical_username}' 2>&1 | \
                    /bin/grep -Pq '^#?Account exists'",
        require => [
            MediaWiki::Wiki[$::mediawiki::wiki_name],
            Env::Var['MW_INSTALL_PATH'],
        ],
    }

    if ! empty($groups) {
        $comma_groups = join($groups, ',')

        $comma_groups_php = join($groups, "', '")

        # eval.php requires each command to be a single line
        # double-escape $ against puppet + shell
        $eval_unless = "
            \\\$u = User::newFromName( '${username}' );
            \\\$u->load( User::READ_LATEST );
            \\\$expected_groups = array_intersect( [ '${comma_groups_php}' ], User::GetAllGroups() );
            \\\$actual_groups = \\\$u->getGroups();
            echo array_diff( \\\$expected_groups, \\\$actual_groups ) ? 'Bad' : 'Good';
        "

        mediawiki::maintenance { "mediawiki_user_${canonical_username}_${wiki}_${comma_groups}":
            command => "/usr/local/bin/mwscript createAndPromote.php --wiki='${wiki}' \
                        --custom-groups '${comma_groups}' \
                        --force '${canonical_username}'",

            # Check that they're already in all the requested groups,
            # using counts.
            unless  => "/bin/echo \"${eval_unless}\" | \
                        /usr/local/bin/mwscript eval.php --wiki='${wiki}' | \
                        /bin/grep -q '^Good$'",
            require => [
                Mediawiki::Maintenance["mediawiki_user_${canonical_username}_${wiki}"],
            ]
        }
    }

    if $email {
        mediawiki::maintenance { "mediawiki_user_${canonical_username}_${wiki}_email":
            command     => "/usr/local/bin/mwscript resetUserEmail.php --wiki='${wiki}' \
                           '${canonical_username}' '${email}' --no-reset-password",
            refreshonly => true,
            subscribe   => Mediawiki::Maintenance["mediawiki_user_${canonical_username}_${wiki}"],
        }
    }
}
