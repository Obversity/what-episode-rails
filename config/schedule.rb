
cap_path = "/var/www/what_episode_rails"

set :output, "#{cap_path}/shared/log/cron_log.log"

every 1.week do
  command "ruby #{cap_path}/current/lib/tasks/get_shows.rb"
end
