require 'mediawiki-vagrant/settings/definitions'

Given(/^the "([^"]+)" setting is "([^"]+)"$/) do |name, value|
  @mwv.configure_settings do |settings|
    settings[name] = value
  end
end

Given(/^the "([^"]+)" setting is not configured$/) do |name|
  @mwv.configure_settings do |settings|
    settings.setting(name).unset!
  end
end

Then(/^the "([^"]+)" setting should be "([^"]+)"$/) do |name, value|
  settings = @mwv.load_settings

  setting = settings.setting(name)
  existing_value = setting.value
  setting.value = value

  expect(existing_value).to eq(setting.value)
end

Then(/^the "([^"]+)" setting should not be configured$/) do |name|
  settings = @mwv.load_settings
  expect(settings[name]).to be(nil)
end

Then(/^the current settings should be:$/) do |table|
  settings = @mwv.load_settings

  table.raw.each do |(name, value)|
    setting = settings.setting(name)
    existing_value = setting.value
    setting.value = value

    expect(existing_value).to eq(setting.value)
  end
end
