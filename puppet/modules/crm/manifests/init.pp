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
    $base_url = "http://${::crm::site_name}${::port_fragment}/"

    include ::php
    include ::postfix
    include ::crm::apache
    include ::crm::civicrm
    include ::crm::tools

    git::clone { $repo:
        directory => $dir,
    }

    php::composer::install { 'crm-composer':
        directory => $dir,
        require   => Git::Clone[$repo],
    }

    service::gitupdate { 'crm':
        dir    => $dir,
        type   => 'php',
        update => true,
    }

    # required by module ganglia_reporter
    package { 'ganglia-monitor': }

    class { 'crm::drupal':
        modules  => [
            'adyen_audit',
            'amazon_audit',
            'astropay_audit',
            'civicrm',
            'contribution_audit',
            'contribution_tracking',
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
            'twigext_l10n_tests',
            'wmf_audit',
            'wmf_campaigns',
            'wmf_civicrm',
            'wmf_common',
            'wmf_communication',
            'wmf_communication_tests',
            'wmf_contribution_search',
            'wmf_fredge_qc',
            'wmf_logging',
            'wmf_refund_qc',
            'wmf_reports',
            'wmf_test_settings',
            'wmf_unsubscribe',
            'wmf_unsubscribe_qc',
            'wmf_zendesk_reports',
            'worldpay_audit',
        ],
        settings => {
            'environment_indicator_enabled'                        => 1,
            'environment_indicator_text'                           => 'DEVELOPMENT',
            'environment_indicator_position'                       => 'left',
            'environment_indicator_color'                          => '#3FBF57',
            'amazon_audit_log_search_past_days'                    => 7,
            'amazon_audit_recon_completed_dir'                     => '/var/spool/audit/amazon/completed',
            'amazon_audit_recon_files_dir'                         => '/var/spool/audit/amazon/incoming/',
            'amazon_audit_working_log_dir'                         => '/tmp/amazon_audit/',
            'astropay_audit_log_search_past_days'                  => 7,
            'astropay_audit_recon_completed_dir'                   => '/var/spool/audit/astropay/completed',
            'astropay_audit_recon_files_dir'                       => '/var/spool/audit/astropay/incoming/',
            'astropay_audit_working_log_dir'                       => '/tmp/astropay_audit/',
            'banner_history_queue'                                 => '/queue/banner-history',
            'donationqueue_url'                                    => "tcp://${::activemq::hostname}:${::activemq::port}",
            'fredge_payments_antifraud_queue'                      => '/queue/payments-antifraud',
            'fredge_payments_init_queue'                           => '/queue/payments-init',
            'queue2civicrm_batch'                                  => 5,
            'queue2civicrm_batch_time'                             => 90,
            'queue2civicrm_gateways_to_monitor'                    => 'adyen,amazon,astropay,globalcollect,paypal,worldpay',
            'queue2civicrm_gmetric_dmax'                           => 360,
            'queue2civicrm_gmetric_tmax'                           => 60,
            'queue2civicrm_subscription'                           => '/queue/donations',
            'queue2civicrm_url'                                    => "tcp://${::activemq::hostname}:${::activemq::port}",
            'recurring_globalcollect_batch'                        => 1,
            'recurring_globalcollect_batch_max'                    => 100,
            'recurring_globalcollect_failure_retry_rate'           => 1,
            'recurring_globalcollect_failures_before_cancellation' => 3,
            'recurring_globalcollect_run_missed_days'              => 7,
            'recurring_subscription'                               => '/queue/donations_recurring',
            'refund_batch'                                         => 0,
            'refund_batch_time'                                    => 90,
            'refund_queue'                                         => '/queue/refund',
            'thank_you_days'                                       => 14,
            'thank_you_batch'                                      => 100,
            'unsubscribe_queue'                                    => '/queue/unsubscribe',
            'worldpay_audit_log_search_past_days'                  => 7,
            'worldpay_audit_recon_completed_dir'                   => '/var/spool/audit/worldpay/completed',
            'worldpay_audit_recon_files_dir'                       => '/var/spool/audit/worldpay/incoming/',
            'worldpay_audit_working_log_dir'                       => '/tmp/worldpay_audit/',
        },
        require  => Php::Composer::Install['crm-composer'],
    }
}
