# == Class: role::poem
# The poem extension
class role::poem {
    mediawiki::extension { 'Poem': }
}
