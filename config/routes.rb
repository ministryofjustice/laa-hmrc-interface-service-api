Rails.application.routes.draw do
  root to: 'main#show'
  get 'main', to: 'main#show', format: :json
  get 'ping', to: 'status#ping', format: :json
  get 'health_check', to: 'status#health_check', format: :json
  get 'status', to: 'status#ping', format: :json
end
