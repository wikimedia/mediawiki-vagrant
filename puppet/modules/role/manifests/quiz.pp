# == Class: role::quiz
# Quiz is the quiz building tool adopted on the Wikiversity.
#
class role::quiz {
    include ::role::mediawiki
    mediawiki::extension { 'Quiz': }
}
