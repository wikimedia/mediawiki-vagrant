# == Class: crm
#
# Drupal + CiviCRM system for managing donor contact info
#
# === Parameters
#
# [*dir*]
#   Root directory for the code
#
# [*site_name*]
#   fqdn for generating resource URLs
#
# [*drupal_db*]
#   Drupal database name
#
# [*civicrm_db*]
#   CiviCRM database name
#
# [*db_user*]
#   Database user
#
# [*db_pass*]
#   Database user's password
#
class crm(
    $dir,
    $site_name,
    $drupal_db,
    $civicrm_db,
    $db_user,
    $db_pass,
) {
    $repo = 'wikimedia/fundraising/crm'

    include ::php
    include ::phpmailer
    include ::postfix
    include ::twig
    include ::crm::apache
    include ::crm::civicrm

    git::clone { $repo:
        directory => $dir,
    }

    php::composer::install { 'crm-composer':
        directory => $dir,
        require => Git::Clone[$repo],
    }

    # required by module ganglia_reporter
    package { 'ganglia-monitor': }

    class { 'crm::drupal':
        modules  => [
            'civicrm',
            'contribution_audit',
            'contribution_tracking',
            'devel',
            'donor_review',
            'environment_indicator',
            'exchange_rates',
            'ganglia_reporter',
            'globalcollect_audit',
            'large_donation',
            'log_audit',
            'offline2civicrm',
            'oneoffs',
            'paypal_audit',
            'queue2civicrm',
            'recurring',
            'recurring_globalcollect',
            'syslog',
            'thank_you',
            'wmf_civicrm',
            'wmf_common',
            'wmf_communication',
            'wmf_contribution_search',
            'wmf_fredge_qc',
            'wmf_logging',
            'wmf_refund_qc',
            'wmf_reports',
            'wmf_unsubscribe',
            'wmf_unsubscribe_qc',
            'devel',
            'queue2civicrm_tests',
            'simpletest',
            'twigext_l10n_tests',
            'wmf_communication_tests',
            'wmf_test_settings',
        ],
        settings => {
            'environment_indicator_enabled'  => 1,
            'environment_indicator_text'     => 'DEVELOPMENT',
            'environment_indicator_position' => 'left',
            'environment_indicator_color'    => '#3FBF57',
        },
        require => Php::Composer::Install['crm-composer'],
    }
}
