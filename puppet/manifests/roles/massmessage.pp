# == Class: role::massmessage
# This role provisions the MassMessage extension, which allows users to
# easily send a message to a list of pages via the job queue, and a set
# of extensions which integrate with it: LiquidThreads, Echo, and MLEB.
class role::massmessage {
    include role::mediawiki
    include role::echo
    include role::mleb

    mediawiki::extension { 'MassMessage': }

    mediawiki::extension { 'LiquidThreads':
        needs_update => true,
        settings     => {
            wgLqtTalkPages => false,
        },
    }
}
