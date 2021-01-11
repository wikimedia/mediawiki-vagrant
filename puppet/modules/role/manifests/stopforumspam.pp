# == Class: role::stopforumspam
# Configures stopforumspam, a MediaWiki extension that allows blocking
# access to the wiki using https://www.stopforumspam.com/ lists
class role::stopforumspam {
    mediawiki::extension { 'StopForumSpam':
        settings => {
            wgSFSIPListLocation    => 'https://www.stopforumspam.com/downloads/listed_ip_90_ipv46_all.gz',
            wgSFSIPListLocationMD5 => 'https://www.stopforumspam.com/downloads/listed_ip_90_ipv46_all.gz.md5',
            wgSFSReportOnly        => true,
        },
    }
}