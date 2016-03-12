# == Class: role::uploadslink
# The UploadsLink extension adds a link to the personal uploads listing,
# within the personal tools menu and one to the Tools-box on user pages
# and pages that relate to a user.
class role::uploadslink {
    mediawiki::extension { 'UploadsLink': }
}
