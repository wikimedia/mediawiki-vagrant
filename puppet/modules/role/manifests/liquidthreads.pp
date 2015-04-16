# == Class: role::liquidthreads
# Configures LiquidThreads, a MediaWiki discussion system (note:
# LiquidThreads is not being actively developed)
class role::liquidthreads {
    include ::role::echo
    include ::role::wikieditor

    mediawiki::extension { 'LiquidThreads':
        settings => {
            wgLqtTalkPages => false
        }
    }
}
