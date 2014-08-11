# == Class: role::featuredfeeds
# The FeaturedFeeds extension allows wikis to publish syndication feeds
# of their content
class role::featuredfeeds {
include role::mediawiki

  mediawiki::extension { 'FeaturedFeeds': }
}
