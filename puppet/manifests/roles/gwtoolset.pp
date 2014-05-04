# == Class: role::gwtoolset
# This role provisions the [GWToolset][1] extension,
# which does mass image and metadata uploading
# based on an XML description.
#
# [1] https://www.mediawiki.org/wiki/Extension:GWToolset
class role::gwtoolset {
    include role::mediawiki
    include role::multimedia

    php::ini { 'GWToolset':
        settings => {
            memory_limit => '256M',
        }
    }

    mediawiki::extension { 'GWToolset':
        settings => template('gwtoolset-config.php.erb'),
    }
}
