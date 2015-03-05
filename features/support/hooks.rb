require 'mediawiki-vagrant/environment'

require 'vagrant'
require 'vagrant/bundler'
require 'vagrant/cli'
require 'vagrant/util/platform'

AfterConfiguration do
  FileUtils.mkdir_p('tmp/testenv/home')
  FileUtils.mkdir_p('tmp/testenv/mwv')

  excludes = "--exclude=/Gemfile --exclude=/vendor --exclude=/.git --exclude=/tmp"
  system("rsync -a #{excludes} --filter='dir-merge,- .gitignore' ./ 'tmp/testenv/mwv/'")
end

Before do
  RSpec::Mocks.setup
end

Before do
  # Create a clean environment for each scenario by copying the working
  # directory to a temporary location
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

  @output = ''

  @vagrant = Vagrant::Environment.new(
    ui_class: Vagrant::UI::Colored,
    cwd: @mwv.path.to_s,
    home_path: @home_path.to_s,
    vagrantfile_name: @mwv.path('Vagrantfile').to_s
  )
end

After do
  @thread.join if @thread

  $stdin = @orig_stdin
  $stdout = @orig_stdout
  $stderr = @orig_stderr

  Dir.chdir(@project_path)
end
