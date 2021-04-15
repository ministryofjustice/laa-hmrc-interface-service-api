Rails.application.routes.draw do
  root to: 'main#show'
  get 'main', to: 'main#show', format: :json
end
