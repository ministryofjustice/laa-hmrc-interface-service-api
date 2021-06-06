REDIS = case Rails.env
        when 'test'
          MockRedis.new
        else
          Redis::Namespace.new('lhisa_uat', redis: Redis.new)
        end
