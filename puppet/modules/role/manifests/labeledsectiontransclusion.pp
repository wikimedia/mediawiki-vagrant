# == Class: role::labeledsectiontransclusion
# Configures LabeledSectionTransclusion, an extension to let you
# include parts of a page.
class role::labeledsectiontransclusion {
    mediawiki::extension { 'LabeledSectionTransclusion': }
}
