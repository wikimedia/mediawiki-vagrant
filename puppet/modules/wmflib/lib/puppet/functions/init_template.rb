# == Function: init_template
#
# Loads a template from a predefined location, and returns its contents.
#
# Based on the value of the two mandatory arguments, the template path will be
# determined as follows:
#
# ${module_name}/initscripts/${arg}.${initsystem}.erb
#
Puppet::Functions.create_function(:init_template) do
  dispatch :init_template do
    param 'String', :tpl_name
    param 'String', :initsystem
  end

  def init_template(tpl_name, initsystem)
    module_name = closure_scope.lookupvar('module_name')
    tpl_arg = "#{module_name}/initscripts/#{tpl_name}.#{initsystem}.erb"
    call_function('template', tpl_arg)
  end
end
