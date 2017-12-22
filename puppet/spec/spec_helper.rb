require 'rspec-puppet'

def puppet_path
  File.expand_path(File.join(__FILE__, '../..'))
end

# Load the modules libraries such as stdlib/wmflib
Dir.glob(File.join(puppet_path, 'modules/*/lib')).each do |module_lib|
  $LOAD_PATH.unshift module_lib
end

def hiera_config_fixture
  fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))
  conf = File.read(File.join(puppet_path, 'hiera.yaml'))
  conf.gsub!(%r{/vagrant/puppet}, puppet_path)

  fixture = File.join(fixture_path, 'hiera.yaml')
  File.write(fixture, conf)

  fixture
end

RSpec.configure do |c|
  c.manifest_dir = File.join(puppet_path, 'manifests')
  # We really want site.pp to be loaded to get hiera('classes') applied
  c.manifest = File.join(puppet_path, 'manifests', 'site.pp')
  c.module_path = File.join(puppet_path, 'modules')
  c.hiera_config = hiera_config_fixture
  c.default_facts = {
    # Debian stretch facts
    # Would be better done with rspec-puppet-facts
    lsbdistrelease: '9.1',
    lsbdistid: 'Debian',
    lsbdistcodename: 'stretch',
    operatingsystem: 'Debian',

    processorcount: 2,
    git_user: 'nobody',
    shared_apt_cache: nil,
    share_group: 'nogroup',
    share_owner: 'nobody',
    site: 'local',
  }

  c.before(:each) do
    # When app_management is activated, Puppet 4.8.2 does not support a
    # define having a parameter named 'site' or 'consume'. rspec-puppet
    # always activate app_management for puppet 4.3.x which thus trigger the
    # bug: Syntax error near 'site'
    # Eg:
    # https://tickets.puppetlabs.com/browse/PUP-6917
    # https://github.com/puppetlabs/puppet/commit/52ff5258a9ce5bc3038f20c913823d370448a7c0
    #
    # Mock Puppet[:app_management] to always return false overriding
    # rspec-puppet behavior.
    # Once migrating to puppet 4.9 or later, this is no more needed.
    allow(Puppet).to receive(:[]).and_call_original
    allow(Puppet).to receive(:[]).with(:app_management).and_return(false)
  end

  # For --next-failure / --only-failures
  c.example_status_persistence_file_path = File.join(
    File.dirname(__FILE__), 'rspec_status')
end
