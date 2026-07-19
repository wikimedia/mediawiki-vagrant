# == Function: shell_exports( hash $variables [, bool $uppercase_keys = true ] )
#
# Generate shell environment variable declarations out of a Puppet hash.
#
# The hash keys are used as the variable names, and the values as
# the variable's values. Values are automatically quoted with double
# quotes. If the second parameter is true (the default), keys are
# automatically uppercased.
#
# === Examples
#
# Invocation:
#
#  shell_exports({
#    apache_run_user => 'apache',
#    apache_pid_file => '/var/run/apache2/apache2.pid',
#  })
#
# Output:
#
#  export APACHE_RUN_USER="apache"
#  export APACHE_PID_FILE="/var/run/apache2/apache2.pid"
#
require 'json'

Puppet::Functions.create_function(:shell_exports) do
  dispatch :shell_exports do
    param 'Hash', :vars
    optional_param 'Any', :uppercase_keys
  end

  def shell_exports(vars, uppercase_keys = true)
    vars = vars.map { |k, v| [k.upcase, v] }.to_h unless uppercase_keys == false
    vars.sort.map { |k, v| "export #{k}=#{v.to_json}" }.push('').join("\n")
  end
end
