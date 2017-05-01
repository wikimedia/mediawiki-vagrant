# == Define: browsertests::bundle
#
# Installs gem dependencies for the given directory of browsertests.
#
# === Examples
#
# Ensure dependencies are installed for the VisualEditor tests.
#
#   browsertests::bundle { '/path/to/extension/browser/tests': }
#
#   browsertests::bundle { 'VisualEditorTests':
#       directory => '/path/to/extension/browser/tests'
#   }
#
define browsertests::bundle(
    $directory = $title,
) {
    include ::browsertests

    ruby::bundle { $title:
        directory  => $directory,
        missing_ok => true,
    }
}
