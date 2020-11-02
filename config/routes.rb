Rails.application.routes.draw do

  root 'static_pages#top'
  get '/signup', to: 'users#new'
  
  #ログイン機能
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  #承認機能
  #get 'attendance_approval'
  #get 'overtime_approval'
  
  resources :users do
    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'
      get 'attendances/month_approval'
    end
    collection do
      post :import
      get :working_index
    end
    resources :attendances, only: :update
  end
  
  resources :hubs
end
