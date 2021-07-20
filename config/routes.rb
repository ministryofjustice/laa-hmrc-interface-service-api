require 'sidekiq/web'

# Configure Sidekiq-specific session middleware
Sidekiq::Web.use ActionDispatch::Cookies
Sidekiq::Web.use Rails.application.config.session_store, Rails.application.config.session_options

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    # Protect against timing attacks:
    # - See https://codahale.com/a-lesson-in-timing-attacks/
    # - See https://thisdata.com/blog/timing-attacks-against-string-comparison/
    # - Use & (do not use &&) so that it doesn't short circuit.
    # - Use digests to stop length information leaking
    secure_compare(username, Settings.sidekiq.username) & secure_compare(password, Settings.sidekiq.web_ui_password)
  end

  root to: 'main#show'
  get 'main', to: 'main#show', format: :json
  get 'ping', to: 'status#ping', format: :json
  get 'health_check', to: 'status#health_check', format: :json
  get 'status', to: 'status#ping', format: :json
  get 'smoke-test', to: 'smoke_test#call', format: :json unless Settings.environment.eql?('live')
end

def secure_compare(passed, stored)
  Rack::Utils.secure_compare(::Digest::SHA256.hexdigest(passed), ::Digest::SHA256.hexdigest(stored))
end
