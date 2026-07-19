# == Function: systemd_template
#
# Loads a template from a predefined location, and returns its contents.
#
# Based on the value of the only mandatory argument, the template path will be
# determined as follows:
#
# ${module_name}/initscripts/${arg}.systemd.erb
#
Puppet::Functions.create_function(:systemd_template) do
  dispatch :systemd_template do
    param 'String', :tpl_name
  end

  def systemd_template(tpl_name)
    call_function('init_template', tpl_name, 'systemd')
  end
end
