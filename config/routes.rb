Rails.application.routes.draw do
  root to: 'main#show'
  get 'main', to: 'main#show', format: :json
  get 'ping', to: 'status#ping', format: :json
  get 'healthcheck', to: 'status#status', format: :json
  get 'status', to: 'status#ping', format: :json
end
