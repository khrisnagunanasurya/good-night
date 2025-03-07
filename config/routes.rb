require 'sidekiq/web'

Rails.application.routes.draw do
  unless Rails.env.production?
    mount Rswag::Ui::Engine => '/api-docs'
    mount Rswag::Api::Engine => '/api-docs'
  end

  mount Sidekiq::Web => '/sidekiq', constraints: SidekiqConstraint.new

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    namespace :v1 do
      resources :users, only: %i[index show create destroy] do
        get :feed, to: 'users#feed'

        get :sleep_records, to: 'users/sleep_records#index'
        post :sleep, to: 'users/sleep_records#sleep'
        post :wake_up, to: 'users/sleep_records#wake_up'

        resources :relationships, param: :target_user_id, only: %i[create destroy], module: :users, controller: :relationships
      end
    end
  end
end
