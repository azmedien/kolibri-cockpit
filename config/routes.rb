Rails.application.routes.draw do
  devise_for :users
  resources :apps
  root to: 'apps#index'

  get '/apps/:id/runtime', to: 'apps#runtime'
end
