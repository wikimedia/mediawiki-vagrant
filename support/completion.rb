project_path = File.expand_path('../..', __FILE__)
$: << File.join(project_path, 'lib')

require 'mediawiki-vagrant/environment'
require 'mediawiki-vagrant/settings/definitions'

mwv = MediaWikiVagrant::Environment.new(project_path)

words =
  case ARGV.shift
  when 'config'
    case ARGV.shift
    when nil, '--get', '--unset'
      MediaWikiVagrant::Settings.definitions.keys
    end
  when 'roles'
    case ARGV.shift
    when nil
      ['disable', 'enable', 'info', 'list', 'reset']
    when 'enable', 'info'
      mwv.roles_available
    when 'disable'
      mwv.roles_enabled
    end
  end

puts words.join(' ') unless words.nil?
