require 'sidekiq/web'

# Configure Sidekiq-specific session middleware
Sidekiq::Web.use ActionDispatch::Cookies
Sidekiq::Web.use Rails.application.config.session_store, Rails.application.config.session_options

Rails.application.routes.draw do
  use_doorkeeper
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
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
  unless Settings.environment.eql?('live')
    get 'smoke-test/:use_case', to: 'smoke_test#call', as: 'smoke-test-use-case', format: :json
    get 'smoke-test', to: 'smoke_test#health_check', format: :json
  end

  namespace :api do
    namespace :v1 do
      post 'submission/create/:use_case', to: 'submissions#create', format: :json
      get 'submission/status/:id', to: 'submissions#status', as: 'submission-status-id', format: :json
      get 'submission/result/:id', to: 'submissions#result', as: 'submission-result-id', format: :json
      get 'use_case/one', to: 'use_case#one', format: :json
      get 'use_case/two', to: 'use_case#two', format: :json
      get 'use_case/three', to: 'use_case#three', format: :json
      get 'use_case/four', to: 'use_case#four', format: :json
    end
  end
end

def secure_compare(passed, stored)
  Rack::Utils.secure_compare(::Digest::SHA256.hexdigest(passed), ::Digest::SHA256.hexdigest(stored))
end
