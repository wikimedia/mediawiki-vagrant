require 'mediawiki-vagrant/environment'

When(/^I enter the following at each prompt:$/) do |inputs|
  inputs = inputs.rows_hash
  prompt_pattern = /(#{inputs.keys.join('|')})/

  inputs.values.each do |input|
    matches = expect_pty_output(prompt_pattern)
    type_on_pty(inputs[matches[1]])
  end
end

When(/^I run vagrant with `([^`]+)`( interactively)?$/) do |arguments, interactively|
  cmd = "#{@bundle} exec vagrant #{arguments}"

  if interactively.nil?
    run_simple(cmd, false)
  else
    run_with_pty(cmd)
  end
end

Then(/^the command should have completed successfully$/) do
  if pty_process?
    expect(status_of_pty_process.exitstatus).to eq(0)
  else
    assert_success(true)
  end
end

Then(/^the (\w+) column of output should contain "([^"]+)"$/) do |col, output|
  expect(output_column(col)).to include(output)
end

Then(/^the (\w+) column of output should contain:$/) do |col, output|
  output = output.respond_to?(:raw) ? output.raw : [[output]]
  column = output_column(col)

  output.each { |(value)| expect(column).to include(value) }
end

Then(/^the tabular output should contain:$/) do |table|
  rows = table.raw
  output = output_table(rows.first.length)

  rows.each { |row| expect(output).to include(row) }
end
