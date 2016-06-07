# == Class: role::pageassessments
# This extension is for the purposes of storing article assessments (for
# WikiProjects) in a new database table.
#
class role::pageassessments {
    mediawiki::extension { 'PageAssessments':
        needs_update => true,
    }
}

