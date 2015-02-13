require 'aruba/cucumber'

require_relative 'interactive_helper'
require_relative 'output_helper'

World(MediaWikiVagrant::InteractiveHelper)
World(MediaWikiVagrant::OutputHelper)
