# == Class: role::xhprof
# This class enables support for function-level hierarchical profiling of PHP
# using XHProf. The graphical interface for the profiler is available at
# /xhprof on the same port as the wiki.
#
# You can add the following code to $IP/StartProfiler.php to use XHProf with
# MediaWiki:
#
#   xhprof_enable( XHPROF_FLAGS_CPU | XHPROF_FLAGS_MEMORY );
#   register_shutdown_function( function() {
#       $profile = xhprof_disable();
#       require_once 'xhprof_lib/utils/xhprof_runs.php';
#       $runs = new XHProfRuns_Default();
#       $runs->save_run( $profile, 'mw' );
#   } );
#
class role::xhprof {
    include role::mediawiki

    include ::xhprof
}
