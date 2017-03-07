Rails.application.routes.draw do
  devise_for :users
  resources :apps
  root to: 'apps#index'

  get '/apps/:id/runtime', to: 'apps#runtime'
  post '/apps/:id/build', to: 'apps#build', as: 'app_build'
end
