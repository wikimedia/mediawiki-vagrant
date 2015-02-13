Before do
  @aruba_timeout_seconds = 10

  # Create a clean environment for each scenario by copying the working
  # directory to Aruba's temporary location
  @env = MediaWikiVagrant::Environment.new(absolute_path('mwv'))

  excludes = "--exclude=/Gemfile --exclude=/vendor --exclude=/.git"
  system("rsync -a #{excludes} --filter='dir-merge,- .gitignore' ./ '#{absolute_path("mwv")}/'")
  create_dir('home')

  set_env('HOME', absolute_path('home'))
  set_env('VAGRANT_HOME', absolute_path('mwv'))

  # Be sure to mute warnings about running vagrant through bundler
  set_env('VAGRANT_I_KNOW_WHAT_IM_DOING_PLEASE_BE_QUIET', 'true')

  cd('mwv')

  # Check for a locally installed bundler
  if File.exist?('vendor/bin/bundle')
    @bundle = File.expand_path('vendor/bin/bundle')
  else
    @bundle = 'bundle'
  end
end

After do
  # Clean up as best we can
  begin
    @env.path.rmtree
  rescue Errno::ENOTEMPTY, Errno::EBUSY
  end
end
