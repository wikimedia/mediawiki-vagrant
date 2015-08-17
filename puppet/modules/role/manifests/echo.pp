# == Class: role::echo
# Configures Echo, a MediaWiki notification framework.
class role::echo {
    include ::role::eventlogging

    mediawiki::extension { 'Echo':
        needs_update => true,
        settings     => {
            wgEchoEnableEmailBatch => false,
            wgAllowHTMLEmail       => true,
        },
    }

    mediawiki::extension { 'Thanks':
        require => Mediawiki::Extension['Echo'],
    }
}
