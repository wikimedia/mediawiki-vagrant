require 'mediawiki-vagrant/environment'

require 'vagrant'
require 'vagrant/bundler'
require 'vagrant/cli'
require 'vagrant/util/platform'

AfterConfiguration do
  # Create an isolated environment for our tests by copying the working
  # directory to a temporary location
  FileUtils.mkdir_p('tmp/testenv/home')
  FileUtils.mkdir_p('tmp/testenv/mwv')

  excludes = '--exclude=/Gemfile --exclude=/vendor --exclude=/.git --exclude=/tmp'
  system("rsync -a #{excludes} --filter='dir-merge,- .gitignore' ./ 'tmp/testenv/mwv/'")
end

Before do
  RSpec::Mocks.setup
end

Before do
  @project_path = Pathname.pwd

  @home_path = @project_path.join('tmp/testenv/home')
  @mwv = MediaWikiVagrant::Environment.new(@project_path.join('tmp/testenv/mwv'))

  Dir.chdir(@mwv.path)

  @orig_stdin = $stdin
  @orig_stdout = $stdout
  @orig_stderr = $stderr

  $stdin, @stdin_w = IO.pipe
  @stdout_r, $stdout = IO.pipe
  @stderr_r, $stderr = IO.pipe

  @vagrant = Vagrant::Environment.new(
    ui_class: Vagrant::UI::Colored,
    cwd: @mwv.path.to_s,
    home_path: @home_path.to_s,
    vagrantfile_name: @mwv.path('Vagrantfile').to_s
  )

  # Clear settings and role state before each scenario
  settings = @mwv.path('.settings.yaml')
  settings.delete if settings.exist?
  Dir.glob(@mwv.path('puppet/modules/role/settings/*.yaml')).each { |path| FileUtils.rm(path) }
  @mwv.update_roles([])
end

After do
  @thread.join if @thread

  $stdin = @orig_stdin
  $stdout = @orig_stdout
  $stderr = @orig_stderr

  Dir.chdir(@project_path)
end
