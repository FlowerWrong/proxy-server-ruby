require 'yaml'
require 'active_support/core_ext/hash/keys'

PROXY_CONFIG = YAML.load(File.open(File.dirname(__FILE__) + '/setting.yml')).symbolize_keys
default_config = PROXY_CONFIG[:proxy].symbolize_keys

domains = default_config[:hosts].split(' ')
deploy_paths = default_config[:deploy_path].split(' ')
rvm_paths = default_config[:rvm_path].split(' ')
ssh_users = default_config[:ssh_user].split(' ')
rvm_defaults = default_config[:rvm_default].split(' ')

require 'mina/bundler'
require 'mina/git'
require 'mina/rvm'

set :domain, domains[0]
set :deploy_to, deploy_paths[0]
set :repository, 'https://github.com/FlowerWrong/proxy-server-ruby.git'
set :branch, 'master'

# For system-wide RVM install.
set :rvm_path, rvm_paths[0]

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, ['log/proxy_server.log']

# Optional settings:
set :user, ssh_users[0]    # Username in the server to SSH to.
#   set :port, '30000'     # SSH port number.
#   set :forward_agent, true     # SSH forward_agent.

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # For those using RVM, use this to load an RVM version@gemset.
  invoke rvm_defaults[0].to_sym
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/log"]

  queue! %[touch "#{deploy_to}/#{shared_path}/log/proxy_server.log"]
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
      queue! %[touch "#{deploy_to}/current/log/proxy_server.log"]
      queue! %[cd "#{deploy_to}/current/"]
      queue 'god restart -c proxy.god'
    end
  end
end


# https://github.com/mina-deploy/mina/issues/8
set :domains, domains

desc "Setup to all servers"
task :setup_all do
  isolate do
    domains.each_with_index do |domain, index|
      set :domain, domain
      set :deploy_to, deploy_paths[index]
      set :rvm_path, rvm_paths[index]
      set :user, ssh_users[index]
      task :environment do
        invoke rvm_defaults[index].to_sym
      end
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