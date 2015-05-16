# == Class: role::sandboxlink
# The SandboxLink extension adds a link to a personal sandbox to
# the personal tools menu.
class role::sandboxlink {
    mediawiki::extension { 'SandboxLink': }
}
