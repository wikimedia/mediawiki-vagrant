# == Class: role::newusermessage
# The new user message extension
class role::newusermessage {
    mediawiki::extension { 'NewUserMessage': }
}
