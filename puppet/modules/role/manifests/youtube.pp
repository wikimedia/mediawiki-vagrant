# == Class: role::youtube
# The YouTube extension allows users to embed YouTube and Google Video movies,
# Archive.org audio and video, WeGame and Gametrailers video, Tangler forum,
# and GoGreenTube video.
class role::youtube {

    mediawiki::extension { 'YouTube': }

}
