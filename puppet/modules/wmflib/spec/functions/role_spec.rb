require 'spec_helper'
require 'mocha/test_unit'
describe 'role' do
  before :each do
    scope.stubs(:is_nodescope?).returns(true)
    ['role::test', 'role::test2'].each do |roleclass|
      unless scope.compiler.topscope.find_hostclass(roleclass)
        host_cls = Puppet::Resource::Type.new(:hostclass, roleclass)
        scope.known_resource_types.add_hostclass(host_cls)
      end
    end
  end

  it "should be called with one parameter" do
    is_expected.to run.with_params.and_raise_error(ArgumentError)
  end

  it "throws error if called outside of the node scope" do
    scope.stubs(:is_nodescope?).returns(false)
    is_expected.to run.with_params('cache::text').and_raise_error(Puppet::ParseError)
  end

  it "throws error if called on a non-existing role" do
    is_expected.to run.with_params('foo::bar').and_raise_error(Puppet::ParseError)
  end

  it "includes the role class" do
    is_expected.to run.with_params('test')
  end

  it "raises an error when called more than once in a scope" do
    subject.execute('test2')
    is_expected.to run.with_params('test').and_raise_error(Puppet::ParseError)
  end

  it "adds the keys to the top-scope variable" do
    subject.execute('test', 'test2')
    expect(scope.compiler.topscope.lookupvar('_roles')).to eq({'test' => true, 'test2' => true})
  end

  it "includes the role classes" do
    subject.execute('test')
    expect(scope.find_hostclass('role::test')).to be_an_instance_of(Puppet::Resource::Type)
  end
end
