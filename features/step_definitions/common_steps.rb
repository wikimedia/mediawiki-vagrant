When(/^I run `vagrant ([^`]+)`( interactively)?$/) do |arguments, interactively|
  allow($stdin).to receive(:tty?).and_return(!interactively.nil?)
  allow($stdout).to receive(:tty?).and_return(!interactively.nil?)

  @thread = Thread.new do
    @exit_status = @vagrant.cli(arguments.split)
  end
end

When(/^I enter the following at each prompt:$/) do |inputs|
  inputs.raw.each do |(prompt, input)|
    enter(input)
  end
end

Then(/^the command should have completed successfully$/) do
  @thread.join
  expect(@exit_status).to be(0)
end

Then(/^the output should contain "(.*)"$/) do |output|
  expect(stdout).to include(output)
end

Then(/^the output should contain:$/) do |output|
  expect(stdout).to include(output)
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

Then(/^the output should be:$/) do |output|
  expect(stdout.chomp).to eq(output)
end
