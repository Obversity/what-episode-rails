
cap_path = "/data/what_episode_rails"

set :output, "#{cap_path}/shared/log/cron_log.log"

every 1.week do
  command "bundle exec ruby #{cap_path}/current/lib/tasks/get_shows.rb"
end
