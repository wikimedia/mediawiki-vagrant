# == Define: ::role::thumb_on_404::multiwiki
# Configure a multiwiki instance with thumbs on 404.
# See commons.pp
define role::thumb_on_404::multiwiki {
    require ::role::mediawiki

    $images_path = "/${title}images"

    apache::site_conf { "${title}:thumb.php on 404":
        site    => $::mediawiki::wiki_name,
        content => template('role/thumb_on_404.conf.erb'),
    }
}
