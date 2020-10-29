
Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq' 
  resources :callback, only: [:create]

  api_version(:module => "V1", :header => {:name => "Accept", :value => "application/vnd.textnotify.com; version=1"}) do
    resources :users, param: :_username
    resources :messages, only: [:create]
    resources :jobs, only: [:index]
    resources :notifications, only: [:show]
    post '/auth/login', to: 'authentication#login'
  end  

  get '/*a', to: 'application#not_found'

end
