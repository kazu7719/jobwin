Rails.application.routes.draw do
  devise_for :users
root to: "calendars#index"

resources :users, only:[:edit, :update]
resources :projects, only: [:index, :new, :create, :show] do
  resources :project_tasks, only:[:create]
end
end
