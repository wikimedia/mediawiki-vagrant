# == Class: role::notebook
# Sets up the NotebookViewer MW extension
class role::notebook {

    package { [
        'nbconvert',
        'ipython',
        'bleach',
    ]:
        ensure   => present,
        provider => pip,
    }

    mediawiki::extension { 'NotebookViewer':
    }
}
