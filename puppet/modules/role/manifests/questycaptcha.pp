# == Class: role::questycaptcha
#
# Provision ConfirmEdit and enable the QuestyCaptcha plugin.
#
class role::questycaptcha {
    require ::role::confirmedit
    include ::role::mediawiki

    mediawiki::settings { 'QuestyCaptcha':
        values   => template('role/questycaptcha/settings.php.erb'),
        priority => $::load_later,
    }

    mediawiki::import::text { 'VagrantRoleQuestyCaptcha':
        content => template('role/questycaptcha/VagrantRoleQuestyCaptcha.wiki.erb'),
    }
}
