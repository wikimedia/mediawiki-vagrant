Given(/^the following roles are defined:$/) do |roles|
  role_path = @mwv.path('puppet/modules/role/manifests')
  Pathname.glob(role_path.join('*.pp')).each(&:delete)

  roles.raw.each do |(role)|
    role_path.join("#{role}.pp").open('w') { |io| io.write("class role::#{role} {}\n") }
  end
end

Given(/^the "(.*?)" role is defined as:$/) do |role, definition|
  @mwv.path("puppet/modules/role/manifests/#{role}.pp").open('w') { |io| io.write(definition) }
end

Given(/^the "(.*?)" role is enabled$/) do |role|
  @mwv.update_roles(@mwv.roles_enabled + [role])
end

Then(/^the "(.*?)" role should be enabled$/) do |role|
  expect(@mwv.roles_enabled).to include(role)
end

Then(/^the "(.*?)" role should be disabled$/) do |role|
  expect(@mwv.roles_enabled).not_to include(role)
end
