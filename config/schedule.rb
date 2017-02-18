
cap_path = "/var/www/what_episode_rails"

set :output, "#{cap_path}/shared/log/cron_log.log"

ever 1.week do
  comand "ruby #{cap_path}/current/lib/get_shows.rb"
end
