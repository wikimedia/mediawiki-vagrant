# == Class: role::multimediaviewer
# This role provisions the MultimediaViewer[https://www.mediawiki.org/wiki/Extension:MultimediaViewer] extension,
# which shows images and their metadata in a lightbox
# when the user clicks on the thumbnails.
class role::multimediaviewer {
  include ::role::multimedia
  include ::apache::mod::headers

  mediawiki::extension { 'MultimediaViewer':
    browser_tests => true,
  }

  apache::site_conf { 'Content-Disposition: attachment on ?download':
    site    => $mediawiki::wiki_name,
    content => template('role/multimediaviewer/apache2.conf.erb'),
  }

  mediawiki::import::dump { 'page_mediaviewere2etest':
    xml_dump           => '/vagrant/puppet/modules/role/files/multimediaviewer/page/MediaViewerE2ETest.xml',
    dump_sentinel_page => 'MediaViewerE2ETest',
  }
}
