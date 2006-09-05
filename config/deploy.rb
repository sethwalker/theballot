# This defines a deployment "recipe" that you can feed to capistrano
# (http://manuals.rubyonrails.com/read/book/17). It allows you to automate
# (among other things) the deployment of your application.

# =============================================================================
# REQUIRED VARIABLES
# =============================================================================
# You must always specify the application and repository for every recipe. The
# repository must be the URL of the repository you want this recipe to
# correspond to. The deploy_to path must be the path on each machine that will
# form the root of the application path.

set :application, "voterguides"
set :repository, "https://svn.radicaldesigns.org/#{application}/trunk"

# =============================================================================
# ROLES
# =============================================================================
# You can define any number of roles, each of which contains any number of
# machines. Roles might include such things as :web, or :app, or :db, defining
# what the purpose of each machine is. You can also specify options that can
# be used to single out a specific subset of boxes in a particular role, like
# :primary => true.

role :web, "gertie.radicaldesigns.org"
#role :web, "208.101.22.167"
role :app, "gertie.radicaldesigns.org"
#role :app, "208.101.22.167"
role :db,  "gertie.radicaldesigns.org", :primary => true
#role :db, "208.101.22.167"
role :dev, "gertie.radicaldesigns.org"

# =============================================================================
# OPTIONAL VARIABLES
# =============================================================================
set :deploy_to, "/home/theball/#{application}" # defaults to "/u/apps/#{application}"
set :user, "theball"            # defaults to the currently logged in user
# set :scm, :darcs               # defaults to :subversion
# set :svn, "/path/to/svn"       # defaults to searching the PATH
# set :darcs, "/path/to/darcs"   # defaults to searching the PATH
# set :cvs, "/path/to/cvs"       # defaults to searching the PATH
# set :gateway, "gate.host.com"  # default to no gateway

# =============================================================================
# SSH OPTIONS
# =============================================================================
# ssh_options[:keys] = %w(/Users/seth/.ssh/id_rsa /Users/seth/.ssh/id_dsa)
# ssh_options[:port] = 25

# =============================================================================
# TASKS
# =============================================================================
# Define tasks that run on all (or only some) of the machines. You can specify
# a role (or set of roles) that each task should be executed on. You can also
# narrow the set of servers to a subset of a role by specifying options, which
# must match the options given for the servers to select (like :primary => true)

desc <<DESC
An imaginary backup task. (Execute the 'show_tasks' task to display all
available tasks.)
DESC
task :backup, :roles => :db, :only => { :primary => true } do
  # the on_rollback handler is only executed if this task is executed within
  # a transaction (see below), AND it or a subsequent task fails.
  on_rollback { delete "/tmp/dump.sql" }

  run "mysqldump -u theuser -p thedatabase > /tmp/dump.sql" do |ch, stream, out|
    ch.send_data "thepassword\n" if out =~ /^Enter password:/
  end
end

# Tasks may take advantage of several different helper methods to interact
# with the remote server(s). These are:
#
# * run(command, options={}, &block): execute the given command on all servers
#   associated with the current task, in parallel. The block, if given, should
#   accept three parameters: the communication channel, a symbol identifying the
#   type of stream (:err or :out), and the data. The block is invoked for all
#   output from the command, allowing you to inspect output and act
#   accordingly.
# * sudo(command, options={}, &block): same as run, but it executes the command
#   via sudo.
# * delete(path, options={}): deletes the given file or directory from all
#   associated servers. If :recursive => true is given in the options, the
#   delete uses "rm -rf" instead of "rm -f".
# * put(buffer, path, options={}): creates or overwrites a file at "path" on
#   all associated servers, populating it with the contents of "buffer". You
#   can specify :mode as an integer value, which will be used to set the mode
#   on the file.
# * render(template, options={}) or render(options={}): renders the given
#   template and returns a string. Alternatively, if the :template key is given,
#   it will be treated as the contents of the template to render. Any other keys
#   are treated as local variables, which are made available to the (ERb)
#   template.

desc "Demonstrates the various helper methods available to recipes."
task :helper_demo do
  # "setup" is a standard task which sets up the directory structure on the
  # remote servers. It is a good idea to run the "setup" task at least once
  # at the beginning of your app's lifetime (it is non-destructive).
  setup

  buffer = render("maintenance.rhtml", :deadline => ENV['UNTIL'])
  put buffer, "#{shared_path}/system/maintenance.html", :mode => 0644
  sudo "killall -USR1 dispatch.fcgi"
  run "#{release_path}/script/spin"
  delete "#{shared_path}/system/maintenance.html"
end

# You can use "transaction" to indicate that if any of the tasks within it fail,
# all should be rolled back (for each task that specifies an on_rollback
# handler).

desc "A task demonstrating the use of transactions."
task :long_deploy do
  transaction do
    update_code
    disable_web
    symlink
    migrate
  end

  restart
  enable_web
end

desc <<-DESC
Spinner is run by the default cold_deploy task. Instead of using script/spinner, we're just gonna rely on Mongrel to keep itself up.
DESC
task :spinner, :roles => :app do
  application_port = 3080 #get this from your friendly sysadmin
  run "mongrel_rails start -e production -p #{application_port} -d -c #{current_path}"
end

desc "Restart the web server"
task :restart, :roles => :app do
  begin
    run "cd #{current_path} && mongrel_rails restart"
  rescue RuntimeError => e
    puts e
    puts "Probably not a big deal, so I'll just keep trucking..."
  end
end

desc "Get the correct database.yml on the server."
task :database_yml, :roles => [:app, :db] do
  run <<-CMD
   ln -nfs #{deploy_to}/#{shared_dir}/config/database.yml #{release_path}/config/database.yml
  CMD
end

desc "Set version number and date."
task :revision_number, :roles => :app do
  put(source.current_revision(self).to_s, "#{current_path}/config/revision.yml", :mode => 0444)
end

desc "Get the system ready for database access."
task :after_update_code do
  database_yml
end

desc "Run the full tests on the deployed app." 
task :run_tests do
 run "cd #{release_path} && rake db:test:prepare" 
 run "cd #{release_path} && rake" 
end

desc "Run pre-symlink tasks" 
task :before_symlink do
#  run_tests
end

desc "Symlink attachments folder."
task :after_symlink do
  revision_number
  run "ln -nfs #{shared_path}/public/attachments #{current_path}/public/attachments"
end

desc "tail production log files" 
task :tail_logs, :roles => :app do
  run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
    puts "#{data}" 
    break if stream == :err    
  end
end

desc "remotely console" 
task :dev_console, :roles => :dev do
  input = ''
  run "cd #{current_path} && ./script/console #{ENV['RAILS_ENV']}" do |channel, stream, data|
    next if data.chomp == input.chomp || data.chomp == ''
    print data
    channel.send_data(input = $stdin.gets) if data =~ /^(>|\?)>/
  end
end

