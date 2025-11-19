Rails.application.routes.draw do
  get "dashboard/index"
  get "experiment_results/index"
  get "experiment_results/show"
  get "experiments/index"
  get "experiments/show"
  get "experiments/lab"
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  root "dashboard#index"

  resources :experiments do
    member do
      get :lab
      post :run_step
    end
  end

  resources :experiment_results, only: [:index, :show]

end
