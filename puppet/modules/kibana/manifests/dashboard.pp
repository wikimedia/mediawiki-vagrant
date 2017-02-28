# == Define: kibana::dashboard
#
# === Parameters:
# - $content: Dashboard contents
#
define kibana::dashboard(
    $content,
) {
    $safe_title = regsubst($title, '\W_', '-', 'G')
    $dashboard = {
        'user'      => 'guest',
        'group'     => 'guest',
        'title'     => $safe_title,
        'dashboard' => $content,
    }
    exec { "save dashboard ${title}":
        command => template('kibana/save-dashboard.erb'),
        unless  => template('kibana/check-dashboard.erb'),
        require => Service['elasticsearch'],
    }
}
