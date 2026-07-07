Rails.application.routes.draw do
  get "users/index"
  get "users/show"
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

  # Landing page routes (accessible without subdomain)
  get "landing", to: "landing#index"
  post "redirect_to_tenant", to: "landing#redirect_to_tenant", as: :redirect_to_tenant

  # School registration routes (accessible without subdomain)
  resources :school_registrations, only: [:new, :create]

  # School landing page (accessible on subdomain)
  get "school_landing", to: "school_landing#index", as: :school_landing

  # Handle OPTIONS requests (CORS preflight)
  match "*path", to: "application#options", via: :options
  
  # Defines the root path route ("/")
  # The root will be handled by SchoolLandingController which checks for tenant
  # If no tenant, it redirects to main landing
  get "dashboard", to: "dashboard#index"
  root "school_landing#index"

  # --- Admin Routes ---
  namespace :admin do
    # 1. FIX: Replace 'resources :dashboard' with this:
    get 'dashboard', to: 'dashboard#index', as: :dashboard
    resources :experiments
    # resources :step_actions
    resources :step_actions do
      resources :step_action_labels
      resources :step_action_equipments
      resources :step_action_transfers
    end
    resources :chemicals
    resources :containers
    resources :equipments
    resources :experiments do
      resources :dna_band_configs, only: [:index, :create, :edit, :update, :destroy]
    end
    # Admin root
    root to: 'dashboard#index'
  end

  # --- Faculty Routes ---
  namespace :faculty do
    resources :assignments, only: [:index, :new, :create]
    resources :classrooms, only: [:index, :new, :create, :show] do
      collection do
        get :download_template
      end
      member do
        post :add_student
        post :add_by_email
        post :import_students
        delete :remove_student
      end
    end
  end

  resources :experiments do
    member do
      get :lab
      post :run_step
    end
  end

  resources :users, only: [:index, :show]
  resources :experiment_results, only: [:index, :show]
  resources :lab_sessions
  resources :submissions

end
