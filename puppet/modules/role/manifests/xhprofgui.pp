# == Class: role::xhprofgui
# This class enables a UI for viewing xhprof run data. Xhprof is already
# installed by default for PHP5 and MediaWiki.
#
# To use xhprofgui to profile MediaWiki you can do esomthing like this
# in your StartProfiler.php:
#
# set_include_path( get_include_path() . PATH_SEPARATOR . '/srv/xhprof' );
# xhprof_enable( XHPROF_FLAGS_CPU | XHPROF_FLAGS_MEMORY );
# register_shutdown_function( function() {
#     $profile = xhprof_disable();
#     require_once 'xhprof_lib/utils/xhprof_lib.php';
#     require_once 'xhprof_lib/utils/xhprof_runs.php';
#     $runs = new XHProfRuns_Default();
#     $runs->save_run( $profile, 'mw' );
# } );
#

# Then browse to 127.0.0.1:8080/xhprof to view the data
#
class role::xhprofgui {
    include ::xhprofgui

    require_package('graphviz')
}
