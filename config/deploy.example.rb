require 'mina/bundler'
require 'mina/git'
require 'mina/rvm'

set :domain, 'host'
set :deploy_to, 'deploy_to'
set :repository, 'https://github.com/FlowerWrong/proxy-server-ruby.git'
set :branch, 'master'

# For system-wide RVM install.
# Run 'which rvm'
set :rvm_path, 'rvm_path'

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, ['log']

# Optional settings:
set :user, 'user_name_for_ssh'    # Username in the server to SSH to.
#   set :port, '30000'     # SSH port number.
#   set :forward_agent, true     # SSH forward_agent.

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # For those using RVM, use this to load an RVM version@gemset.
  # Run 'rvm info'
  invoke :'rvm:use[ruby-2.1.6-p336@default]'
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/log"]

  queue! %[mkdir -p "#{deploy_to}/log/proxy_server.log"]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  to :before_hook do
    # Put things to run locally before ssh
  end
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'deploy:cleanup'

    to :launch do
      # queue 'god terminate'
      queue 'god restart -c proxy.god'
    end
  end
end

# ==============================================================================

# If you are using multi servers, edit it.

# https://github.com/mina-deploy/mina/issues/8
set :domains, %w[host1 host2 host3]

desc "Setup to all servers"
task :setup_all do
  isolate do
    domains.each do |domain|
      set :domain, domain
      invoke :setup
      run!
    end
  end
end

desc "Deploy to all servers"
task :deploy_all do
  isolate do
    domains.each do |domain|
      set :domain, domain
      invoke :deploy
      run!
    end
  end
end