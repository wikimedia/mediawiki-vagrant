# == Class: role::gwtoolset
# Provisions the GWToolset[1] extension, which does mass mediafile and metadata
# uploading based on an XML description.
#
# [1] https://www.mediawiki.org/wiki/Extension:GWToolset
class role::gwtoolset {
    # required by gwtoolset
    require ::role::multimedia

    # required by complex templates such as Artwork
    require ::role::parserfunctions
    require ::role::scribunto
    require ::role::templatedata
    require ::role::translate

    # required by codeeditor
    require ::role::wikieditor

    # required by commons templates such as Artwork
    require ::role::wikimediamessages

    php::ini { 'GWToolset':
        settings => {
            memory_limit => '512M'
        }
    }

    mediawiki::extension { 'GWToolset':
        settings => template('role/gwtoolset/conf.php.erb')
    }

    mediawiki::import::dump { 'mediawiki_common_css':
        xml_dump           => '/vagrant/puppet/modules/role/files/gwtoolset/mediawiki/Common.css.xml',
        dump_sentinel_page => 'Mediawiki:Common.css',
    }

    mediawiki::import::dump { 'mediawiki_editsection_brackets':
        xml_dump           => '/vagrant/puppet/modules/role/files/gwtoolset/mediawiki/Editsection-brackets.xml',
        dump_sentinel_page => 'Mediawiki:Editsection-brackets',
    }

    mediawiki::import::dump { 'mediawiki_lang':
        xml_dump           => '/vagrant/puppet/modules/role/files/gwtoolset/mediawiki/Lang.xml',
        dump_sentinel_page => 'Mediawiki:Lang',
    }

    mediawiki::import::dump { 'template_de':
        xml_dump           => '/vagrant/puppet/modules/role/files/gwtoolset/template/De.xml',
        dump_sentinel_page => 'Template:De',
    }

    mediawiki::import::dump { 'template_en':
        xml_dump           => '/vagrant/puppet/modules/role/files/gwtoolset/template/En.xml',
        dump_sentinel_page => 'Template:En',
    }

    mediawiki::import::dump { 'template_fr':
        xml_dump           => '/vagrant/puppet/modules/role/files/gwtoolset/template/Fr.xml',
        dump_sentinel_page => 'Template:Fr',
    }

    mediawiki::import::dump { 'template_nl':
        xml_dump           => '/vagrant/puppet/modules/role/files/gwtoolset/template/Nl.xml',
        dump_sentinel_page => 'Template:Nl',
    }

    mediawiki::import::dump { 'module_templatepar':
        xml_dump           => '/vagrant/puppet/modules/role/files/gwtoolset/module/TemplatePar.xml',
        dump_sentinel_page => 'Module:TemplatePar',
    }

    mediawiki::import::dump { 'template_pd_old':
        xml_dump           => '/vagrant/puppet/modules/role/files/gwtoolset/template/PD-old.xml',
        dump_sentinel_page => 'Template:PD-old',
    }

    mediawiki::import::dump { 'template_pd_us':
        xml_dump           => '/vagrant/puppet/modules/role/files/gwtoolset/template/PD-US.xml',
        dump_sentinel_page => 'Template:PD-US',
    }

    mediawiki::import::dump { 'template_cc_by_30':
        xml_dump           => '/vagrant/puppet/modules/role/files/gwtoolset/template/Cc-by-3.0.xml',
        dump_sentinel_page => 'Template:Cc-by-3.0',
    }

    mediawiki::import::dump { 'template_cc_by_sa_30':
        xml_dump           => '/vagrant/puppet/modules/role/files/gwtoolset/template/Cc-by-sa-3.0.xml',
        dump_sentinel_page => 'Template:Cc-by-sa-3.0',
    }

    mediawiki::import::dump { 'template_uploaded_with_gwtoolset':
        xml_dump           => '/vagrant/puppet/modules/role/files/gwtoolset/template/Uploaded_with_GWToolset.xml',
        dump_sentinel_page => 'Template:Uploaded_with_GWToolset',
    }

    mediawiki::import::dump { 'template_artwork':
        xml_dump           => '/vagrant/puppet/modules/role/files/gwtoolset/template/Artwork.xml',
        dump_sentinel_page => 'Template:Artwork',
    }

    mediawiki::import::dump { 'mapping_beeld_en_geluid':
        xml_dump           => '/vagrant/puppet/modules/role/files/gwtoolset/mapping/GWToolset-Metadata_Mappings-Dan-nl-Beeld-en-Geluid.xml',
        dump_sentinel_page => 'GWToolset:Metadata_Mappings/Dan-nl/Beeld-en-Geluid.json',
    }

    mediawiki::import::dump { 'mapping_kb':
        xml_dump           => '/vagrant/puppet/modules/role/files/gwtoolset/mapping/GWToolset-Metadata_Mappings-Dan-nl-KB_Centsprenten.xml',
        dump_sentinel_page => 'GWToolset:Metadata_Mappings/Dan-nl/KB_Centsprenten.json',
    }

    mediawiki::import::dump { 'mapping_rijksmuseum':
        xml_dump           => '/vagrant/puppet/modules/role/files/gwtoolset/mapping/GWToolset-Metadata_Mappings-Dan-nl-Rijksmuseum.xml',
        dump_sentinel_page => 'GWToolset:Metadata_Mappings/Dan-nl/Rijksmuseum.json',
    }
}
