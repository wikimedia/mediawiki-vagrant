# == Function: file_exists( string $path )
#
# Returns true if the given path exists on the local filesystem.
#
Puppet::Functions.create_function(:file_exists) do
  dispatch :file_exists do
    param 'String', :path
  end

  def file_exists(path)
    File.exist?(path)
  end
end
