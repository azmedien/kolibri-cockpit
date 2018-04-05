Rails.application.routes.draw do

  post 'webhooks/receive'

  devise_for :users

  resources :apps do
    resources :assets do
        get 'download', action: 'download', as: 'download'
    end

    resources :notifications

    post 'notifications/configure', to: 'notifications#configure_notifications'
    post 'autority/invite', to: 'apps#invite', as: 'autority_invite'

    member do
      get 'settings'
      get 'build'
      post 'build', to: 'apps#jenkins', as: 'trigger_build'
      post 'configure', to: 'apps#configure_app', as: 'trigger_configure'
      get 'prepare'
      get 'publish'
      get 'runtime'
    end
  end
  root to: 'apps#index'

  mount ActionCable.server => '/cable'
end
