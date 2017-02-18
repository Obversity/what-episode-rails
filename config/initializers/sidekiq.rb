redis_config = { url: 'redis://127.0.0.1:6379', namespace: 'what' }

Sidekiq.configure_server do |config|
  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end
