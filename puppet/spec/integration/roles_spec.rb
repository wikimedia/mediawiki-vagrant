require 'spec_helper'

role_manifests = File.join(puppet_path, 'modules/role/manifests')

Dir.glob(File.join(role_manifests, '**/*.pp')).sort.each do |role_file|
  relative = Pathname.new(role_file).relative_path_from(Pathname.new(role_manifests))
  role_name = 'role::' + relative.to_s.gsub(%r{(/|\.pp$)}, { '/' => '::', '\.pp' => '' })

  # Sub roles tend to be defines and we can not test them here
  # eg role::thumb_on_404::multiwiki has:
  #   define role::thumb_on_404::multiwiki(
  if role_name.scan(/::/).count >= 2
    manifest = File.read(role_file)
    next if manifest.match(%(^define #{role_name}\\W))
  end

  describe role_name, type: :class do
    # Puppet 4.8.2 does not default to systemd on Stretch
    let(:pre_condition) { 'Service { provider => "systemd" }'}
    it { is_expected.to compile }
  end
end
