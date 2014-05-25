# == Class: crm::apache
#
# Apache site configuration for the Fundraising CRM
#
class crm::apache {
    include ::crm
    include ::apache

    apache::site { $crm::site_name:
        ensure  => present,
        content => template('crm/crm-apache-site.erb'),
        require => Apache::Mod['rewrite'],
    }
}
