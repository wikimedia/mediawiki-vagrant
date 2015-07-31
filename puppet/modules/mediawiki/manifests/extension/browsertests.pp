# == Define: mediawiki::extension::browsertests
#
# This resource type installs the dependencies necessary to execute browser
# tests for a MediaWiki extension.
#
# === Parameters
#
# [*path*]
#   Path to test suite inside of extension directory. If set to false or true,
#   will default to 'tests/browser'.
define mediawiki::extension::browsertests(
    $path = false,
) {
    $dir = $path ? {
        true    => 'tests/browser', # b/c with mediawiki::extension
        false   => 'tests/browser',
        default => $path,
    }

    ::browsertests::bundle { "${title}_browsertests_bundle":
        directory => "${mediawiki::dir}/extensions/${title}/${dir}",
    }
}
