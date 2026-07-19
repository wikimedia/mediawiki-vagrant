# == Function: upstart_template
#
# Loads a template from a predefined location, and returns its contents.
#
# Based on the value of the only mandatory argument, the template path will be
# determined as follows:
#
# ${module_name}/initscripts/${arg}.upstart.erb
#
Puppet::Functions.create_function(:upstart_template) do
  dispatch :upstart_template do
    param 'String', :tpl_name
  end

  def upstart_template(tpl_name)
    call_function('init_template', tpl_name, 'upstart')
  end
end
