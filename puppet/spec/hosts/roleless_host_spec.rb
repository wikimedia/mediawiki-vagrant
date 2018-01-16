require 'spec_helper'

describe 'roleless_host' do
  # Puppet 4.8.2 does not default to systemd on Stretch
  let(:pre_condition) { 'Service { provider => "systemd" }'}
  it { is_expected.to compile }
end
