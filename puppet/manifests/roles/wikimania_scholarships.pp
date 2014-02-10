# == Class: role::wikimania_scholarships
# Provisions the Wikimania Scholarships application.
#
# *Note*: The application is provisioned using an Apache named virtual host.
# Once the role is enabled and provisioned use the URL
# http://scholarships.local.wmftest.net:8080/ to access the site.
class role::wikimania_scholarships {
    include role::generic
    include role::mysql

    class { '::wikimania_scholarships':
        vhost_name => 'scholarships.local.wmftest.net',
        db_name    => 'scholarships',
        db_user    => 'scholarships',
        db_pass    => 'scholarships',
        deploy_dir => '/vagrant/wikimania_scholarships',
    }
}
