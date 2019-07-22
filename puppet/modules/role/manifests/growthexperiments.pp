# == Class: role::growthexperiments
# Configures GrowthExperiments, a MediaWiki extension that contains experiments by the Growth team
#
class role::growthexperiments {
    require ::role::mediawiki
    include ::role::pageviewinfo

    mediawiki::extension { 'GrowthExperiments':
        settings => template('role/growthexperiments/conf.php.erb'),
    }

    mediawiki::import::text { 'Tutorial':
      source => 'puppet:///modules/role/growthexperiments/Tutorial.wiki',
    }

    mediawiki::import::text { 'Project:Help_Desk':
      source => 'puppet:///modules/role/growthexperiments/Project_Help_Desk.wiki',
    }

    mediawiki::user { 'Mentor1':
        password => $::mediawiki::admin_pass,
    }
    mediawiki::import::text { 'Mentors':
        source => 'puppet:///modules/role/growthexperiments/Mentors.wiki',
    }
}
