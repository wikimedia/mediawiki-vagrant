# == Class: role::labledsectiontransclusion
# Configures LabledSectionTransclusion, an extension to let you include parts of a page
class role::labledsectiontransclusion {
    mediawiki::extension { 'LabledSectionTransclusion': }
}
