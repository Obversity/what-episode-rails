# NOTES
#
# Any individual task can be ran from the console like so:
#
#   cap production js:update_repo
#   cap production puma:make_dirs
#
# etc.
#



# config valid only for current version of Capistrano
lock "3.7.2"

set :application, "what_episode_rails"
set :repo_url, "git@github.com:Obversity/what-episode-rails.git"

set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads')
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/application.yml', 'config/secrets.yml')

set :keep_releases, 5

set :migration_role, :app
set :conditionally_migrate, true

set :rbenv_type, :user # or :system, depends on your rbenv setup
# set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_ruby, File.read('.ruby-version').strip

set :puma_threads,    [4, 16]
set :puma_workers,    0

set :puma_bind, -> { "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock" }
set :puma_state, -> { "#{shared_path}/tmp/pids/puma.state" }
set :puma_pid, -> { "#{shared_path}/tmp/pids/puma.pid" }
set :puma_access_log, -> { "#{release_path}/log/puma.access.log" }
set :puma_error_log, -> { "#{release_path}/log/puma.error.log" }
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true

set :nvm_type, :user
set :nvm_node, 'v6.9.4'
set :nvm_map_bins, %w{node npm}

set :js_repo_url, 'https://github.com/Obversity/what-episode-js.git'
set :js_repo_path, -> { "#{shared_path}/js" }

set :deploy_to, "/data/#{fetch(:application)}"


# specify aws cli executable on the server
SSHKit.config.command_map[:aws] = "/home/deploy/.local/bin/aws"

namespace :js do
  # clone or update the js repo
  task :update_repo do
    on roles(:app) do
      # if the js repo dir exists, update it
      if test("[ -d #{fetch(:js_repo_path)} ]")
        within fetch(:js_repo_path) do
          execute :git, 'fetch', '--all'
          execute :git, 'reset', '--hard', 'origin/master'
        end
      else # if repo doesn't exist, clone it
        execute :git, 'clone', fetch(:js_repo_url), fetch(:js_repo_path)
      end
    end
  end

  task :build do
    on roles(:app) do
      within fetch(:js_repo_path) do
        execute :npm, 'install'
        execute :npm, 'run', 'build'
      end
    end
  end

  # symlink the build into the rails public repo
  task :link do
    on roles(:app) do
      execute :ln, '-sf', "#{fetch(:js_repo_path)}/build/*", "#{current_path}/public"
    end
  end

  # sync the build directory up to s3 bucket and invalidate cloudfront cache
  task :sync do
    on roles(:app) do
      within fetch(:js_repo_path) do
        execute :aws, 's3', 'sync', '--profile', 'episodefinder', 'build', 's3://episodefinder'
        execute :aws, 'cloudfront', 'create-invalidation', '--profile=episodefinder', '--distribution-id', 'E2ZLADHXJF7KOV', '--paths', '/index.html'
      end
    end
  end
end


namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end


namespace :deploy do
  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  # The lifecyle (aka flow) hooks, for reference:
  #
  #   deploy:starting    - start a deployment, make sure everything is ready
  #   deploy:started     - started hook (for custom tasks)
  #   deploy:updating    - update server(s) with a new release
  #   deploy:updated     - updated hook
  #   deploy:publishing  - publish the new release
  #   deploy:published   - published hook
  #   deploy:finishing   - finish the deployment, clean up everything
  #   deploy:finished    - finished hook
  #
  after  :updating,     'js:update_repo'
  before :publishing,   'js:build'
  after  :published,    'js:sync'
  after  :finishing,    :cleanup
end
