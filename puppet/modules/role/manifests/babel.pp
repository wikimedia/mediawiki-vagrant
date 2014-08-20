# == Class: role::babel
# On Wikimedia projects, the noun Babel (in reference to the Tower of Babel)
# refers to the texts on user pages aiding multilingual communication by making
# it easier to contact someone who speaks a certain language. The idea
# originated on the Wikimedia Commons and has also been implemented on many
# other wikis.
class role::babel {
    include ::role::cldr

    mediawiki::extension { 'Babel':
        require  => Mediawiki::Extension['cldr'],
    }
}
