# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do # rubocop:disable Metrics/BlockLength
  root to: 'home_pages#index'

  get 'login',  to: 'sessions#new'
  get 'logout', to: 'sessions#destroy'

  resources :users, only: %i[new create edit update] do # rubocop:disable Metrics/BlockLength
    member do
      get :edit_password
      post :update_password
      get :all_posted_jobs
      get :applied_jobs
      get :activate
      get :delete_avatar
    end
    resources :bookmarks, only: %i[index create destroy]
    resources :dashboards, only: [:index] do
      collection do
        get :jobs_posted_by_employers_today
        get :all_jobs_posted_by_admin_and_employers
      end
    end
    resources :work_experiences, only: [:new]
    resources :educations, only: [:new]
    resources :resumes, only: %i[new create destroy] do
      member do
        get :download
      end
    end
    resources :cover_letters, only: %i[new create destroy] do
      member do
        get :download
      end
    end
  end

  resources :sessions,  only: %i[new create destroy]
  resources :companies, only: %i[create edit update] do
    member do
      get :delete_logo
    end
  end
  resources :jobs do
    member do
      get :close_job
      get :reopen_job
      get :closed_by_admin
      get :reopened_by_admin
    end
    resources :applicants, only: %i[index show new create] do
      member do
        get :shortlist
        get :reject
        get :download_resume
        get :download_cover_letter
      end
    end
  end

  resources :password_resets, only: %i[new create edit update]
  resources :categories, only: [:index]
  resources :admin_areas, only: [:index] do
    collection do
      get :expire_jobs
      get :delete_admin_expired_jobs
      get :delete_all_expired_jobs
    end
  end

  mount Sidekiq::Web => '/sidekiq'

  get 'terms_and_conditions', to: 'static_pages#terms_and_conditions'
  get 'privacy_policy', to: 'static_pages#privacy_policy'

  # This routing are for render :new when render :new changes the url. we may need to delete some of these in future
  # when we add other actions in controller.
  get '/users/:user_id/resumes', to: 'resumes#new'
  get '/users/:id/update_password', to: 'users#edit_password'
  get '/users/:user_id/cover_letters', to: 'cover_letters#new'
  get '/companies/:id', to: 'companies#edit' # delete this when we implement Companies#show action
end
