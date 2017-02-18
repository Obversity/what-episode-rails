
cap_path = "/var/www/what_episode_rails"

set :output, "#{cap_path}/shared/log/cron_log.log"

every 1.week do
  command "bundle exec ruby /var/www/what_episode_rails/current/lib/tasks/get_shows.rb"
end
