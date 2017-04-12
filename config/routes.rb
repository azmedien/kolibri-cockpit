Rails.application.routes.draw do

  post 'webhooks/receive'

  devise_for :users
  resources :apps do
    resources :assets
    member do
      get 'settings'
      get 'build'
      post 'build', to: 'apps#jenkins', as: 'trigger_build'
      get 'prepare'
      get 'publish'
      get 'runtime'
    end
  end
  root to: 'apps#index'

  mount ActionCable.server => '/cable'
end
