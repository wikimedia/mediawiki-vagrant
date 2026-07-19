require 'pathname'

Puppet::Functions.create_function(:secret) do
  dispatch :secret do
    param 'String', :in_path
  end

  def secret(in_path)
    mod_name = 'secret'
    secs_subdir = '/secrets/'

    mod = Puppet::Module.find(mod_name)
    fail("secret(): Module #{mod_name} not found") unless mod
    mod_path = mod.path

    sec_path = mod_path + secs_subdir + in_path
    final_path = Pathname.new(sec_path).cleanpath

    # Bail early if it's not a regular, readable file
    unless final_path.file? && final_path.readable?
      fail(ArgumentError, "secret(): invalid secret #{in_path}")
    end

    final_path.read
  end
end
