# Scheduled in whenever.rb as cronjob
# written as plain ruby task to avoid booting
# entire rails application just to send job to sidkiq
require 'securerandom'
require 'redis'
require 'json'

redis = Redis.new(url: 'redis://127.0.0.1:6379')
msg = {
  class: 'Sidekiq::Extensions::DelayedClass',
  args: ["---\n- !ruby/class 'Crawler'\n- :get_shows\n- []\n"],
  jid: SecureRandom.hex(12),
  retry: true,
  enqueued_at: Time.now.to_f,
}
redis.lpush('what:queue:default', JSON.dump(msg))
