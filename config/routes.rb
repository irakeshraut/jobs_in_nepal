Rails.application.routes.draw do
  root to: 'home_pages#index'

  get 'login',  to: 'sessions#new'
  get 'logout', to: 'sessions#destroy'

  resources :users
  resources :sessions,  only: [:new, :create, :destroy]
  resources :companies, only: [:create]
end
