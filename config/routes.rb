require 'sidekiq/web'

Rails.application.routes.draw do
  root to: 'home_pages#index'

  get 'login',  to: 'sessions#new'
  get 'logout', to: 'sessions#destroy'

  resources :users, only: [:new, :create, :edit, :update] do
    member do
      get :edit_password
      post :update_password
      get :all_posted_jobs
      get :applied_jobs
      get :activate
    end
    resources :bookmarks, only: [:index, :create, :destroy]
    resources :dashboards, only: [:index]
    resources :work_experiences, only: [:new]
    resources :educations, only: [:new]
    resources :resumes, only: [:new, :create, :destroy] do
      member do
        get :download
      end
    end
    resources :cover_letters, only: [:new, :create, :destroy] do
      member do
        get :download
      end
    end
  end

  resources :sessions,  only: [:new, :create, :destroy]
  resources :companies, only: [:create, :edit, :update]
  resources :jobs do
    resources :applicants, only: [:index, :show, :new, :create] do
      member do
        get :shortlist
        get :reject
        get :download_resume
        get :download_cover_letter
      end
    end
  end

  resources :password_resets, only: [:new, :create, :edit, :update]

  mount Sidekiq::Web => '/sidekiq'

  get 'terms_and_conditions', to: 'static_pages#terms_and_conditions'
  get 'privacy_policy', to: 'static_pages#privacy_policy'
end
