# == Define: browsertests::bundle
#
# Installs gem dependencies for the given directory of browsertests.
#
# === Examples
#
# Ensure dependencies are installed for the VisualEditor tests.
#
#   browsertests::bundle { '/vagrant/mediawiki/extensions/VisualEditor/modules/ve-mw/test/browser': }
#
define browsertests::bundle {
    include browsertests
    include ruby::default

    ruby::bundle { $title: }
}

