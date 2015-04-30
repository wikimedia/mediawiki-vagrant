# == Class: role::contactpage
# Install the ContactPage extension and a mail server that will redirect all
# emails to the vagrant user.
#
# No contact forms are configured by default. Create configuration files in
# /vagrant/settings.d to configure specific forms.
#
class role::contactpage {
    require ::role::mediawiki
    include ::postfix

    require_package('mailutils')
    mediawiki::extension { 'ContactPage':
        settings => [
            '$wgContactConfig["default"]["RecipientUser"] = "RecipientUser";',
        ],
    }

    mediawiki::user { 'RecipientUser':
        password => $::mediawiki::admin_pass,
        email    => 'RecipientUser@example.org',
    }
}
