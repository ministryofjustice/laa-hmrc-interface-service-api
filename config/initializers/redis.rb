REDIS = Redis::Namespace.new("lhisa_uat", redis: Redis.new) unless Rails.env.test?
