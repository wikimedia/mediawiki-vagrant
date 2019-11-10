# == Class: role::hitcounters
# The HitCounters[1] extension displays pageview
# new namespaces.
class role::hitcounters {
    mediawiki::extension { 'HitCounters':
        needs_update => true,
    }
}
