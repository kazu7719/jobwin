Rails.application.routes.draw do
  devise_for :users
root to: "calendars#index"

resources :users, only:[:edit, :update]
resources :projects do
  resources :project_tasks, only:[:create]
end
resources :tasks, only:[:index, :new, :create]
end
