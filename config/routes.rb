Rails.application.routes.draw do
  root to: 'home_pages#index'

  get 'login',  to: 'sessions#new'
  get 'logout', to: 'sessions#destroy'

  resources :users, only: [:new, :create, :edit, :update] do
    member do
      post :update_password
    end
  end

  resources :sessions,  only: [:new, :create, :destroy]
  resources :companies, only: [:create]
  resources :dashboards, only: [:index]
  resources :jobs, only: [:index, :show, :new, :create]
end
