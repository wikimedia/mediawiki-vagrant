# == Class: role::xhprofgui
# This class enables a UI for viewing xhprof run data. Xhprof is already
# installed by default.

# Browse to 127.0.0.1:8080/xhprof to view the data
#
class role::xhprofgui {
    include ::xhprofgui

    mediawiki::settings { 'xhprof':
        values => {
            'wgProfiler' => {
                'class'     => 'ProfilerXhprof',
                'output'    => [ 'ProfilerOutputDump' ],
                'outputDir' => $::php::xhprof::profile_storage_dir,
            },
        }
    }

    require_package('graphviz')
}
