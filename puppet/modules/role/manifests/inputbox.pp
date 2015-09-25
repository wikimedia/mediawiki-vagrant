# == Class: role::inputbox
# The InputBox[1] extension extension adds support for embedding
# simple navigational forms in wikitext.
#
# [1] https://www.mediawiki.org/wiki/Extension:InputBox
class role::inputbox {
    mediawiki::extension { 'InputBox': }
}
