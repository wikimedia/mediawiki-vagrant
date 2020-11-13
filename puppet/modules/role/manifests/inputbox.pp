# == Class: role::inputbox
# The InputBox[https://www.mediawiki.org/wiki/Extension:InputBox]
# extension extension adds support for embedding simple navigational
# forms in wikitext.
#
class role::inputbox {
    mediawiki::extension { 'InputBox': }
}
