# == Class: role::usermerge
# The UserMerge extension allows wiki users with the usermerge permission
# (Bureaucrat by default) to merge one Wiki user's account with another Wiki
# user's account.
class role::usermerge {
    mediawiki::extension { 'UserMerge': }
}
