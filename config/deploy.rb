require 'cap_ssh_ports'

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

set :keep_releases, 3
set :application, 'theballot'
set :repository,   'https://svn.radicaldesigns.org/voterguides/trunk/'
set :svn_username, ''
set :svn_password, ''


# =============================================================================
# ROLES
# =============================================================================
# You can define any number of roles, each of which contains any number of
# machines. Roles might include such things as :web, or :app, or :db, defining
# what the purpose of each machine is. You can also specify options that can
# be used to single out a specific subset of boxes in a particular role, like
# :primary => true.

role :web, "theballot@65.74.169.199:8050"
role :app, "theballot@65.74.169.199:8050"
role :app,  "theballot@65.74.169.199:8051", :no_release => true, :no_symlink => true
role :db,  "theballot@65.74.169.199:8050", :primary => true

# =============================================================================
# OPTIONAL VARIABLES
# =============================================================================

set :deploy_to, "/data/#{application}"

# =============================================================================
# SSH OPTIONS
# =============================================================================
task :uname, :roles => [:app, :prod_slave] do
  run "uname -a"
end


  desc <<-DESC
  Restart the Mongrel processes on the app server by calling restart_mongrel_cluster.
  DESC
  task :restart, :roles => :app do
    restart_mongrel_cluster
  end

  desc <<-DESC
  Start the Mongrel processes on the app server by calling start_mongrel_cluster.
  DESC
  task :spinner, :roles => :app do
    start_mongrel_cluster
  end


desc <<-DESC
Start Mongrel processes on the app server.  This uses the :use_sudo variable to determine whether to use sudo or not. By default, :use_sudo is
set to true.
DESC
task :start_mongrel_cluster , :roles => :app do
  sudo "/etc/init.d/mongrel_cluster start"
end

desc <<-DESC
Restart the Mongrel processes on the app server by starting and stopping the cluster. This uses the :use_sudo
variable to determine whether to use sudo or not. By default, :use_sudo is set to true.
DESC
task :restart_mongrel_cluster , :roles => :app do
  sudo "/etc/init.d/mongrel_cluster restart"
end

desc <<-DESC
Stop the Mongrel processes on the app server.  This uses the :use_sudo
variable to determine whether to use sudo or not. By default, :use_sudo is
set to true.
DESC
task :stop_mongrel_cluster , :roles => :app do
  sudo "/etc/init.d/mongrel_cluster stop"
end


# =============================================================================
# TASKS
# =============================================================================
# Define tasks that run on all (or only some) of the machines. You can specify
# a role (or set of roles) that each task should be executed on. You can also
# narrow the set of servers to a subset of a role by specifying options, which
# must match the options given for the servers to select (like :primary => true)
#ln -s #{shared_path}/database.yml #{release_path}/config/database.yml &&
task :after_update_code, :roles => :app, :except => {:no_symlink => true} do
  run <<-CMD
    cd #{release_path} &&
    ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml &&
    ln -nfs #{shared_path}/config/mongrel_cluster.yml #{release_path}/config/mongrel_cluster.yml
  CMD
end

task :after_symlink, :roles => :app , :except => {:no_symlink => true} do
  sudo "ln -nfs #{shared_path}/public/themes #{release_path}/public/themes"
  sudo "chmod 755 #{release_path}/public/themes/default.liquid"
  sudo "ln -nfs #{shared_path}/public/attachments #{release_path}/public/attachments"
end 
