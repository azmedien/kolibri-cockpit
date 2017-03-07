Rails.application.routes.draw do
  post 'webhooks/receive'

  devise_for :users
  resources :apps
  root to: 'apps#index'

  mount ActionCable.server => '/cable'

  get '/apps/:id/runtime', to: 'apps#runtime'
  post '/apps/:id/build', to: 'apps#build', as: 'app_build'
end
