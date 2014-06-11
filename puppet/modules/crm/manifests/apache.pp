# == Class: crm::apache
#
# Apache site configuration for the Fundraising CRM
#
class crm::apache {
    include ::crm
    include ::apache
    include ::apache::mod::rewrite

    apache::site { $crm::site_name:
        ensure  => present,
        content => template('crm/crm-apache-site.erb'),
        require => Class['::apache::mod::rewrite'],
    }
}
