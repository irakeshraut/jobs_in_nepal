Rails.application.routes.draw do
  root to: 'home_pages#index'

  get 'login',  to: 'sessions#new'
  get 'logout', to: 'sessions#destroy'

  resources :users, only: [:new, :create, :edit, :update] do
    member do
      post :update_password
    end
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
  resources :dashboards, only: [:index]
  resources :jobs do
    collection do
      get :all_posted_jobs
    end
    resources :applicants, only: [:index, :show, :new, :create] do
      member do
        get :shortlist
        get :reject
        get :download_resume
        get :download_cover_letter
      end
    end
  end
end
