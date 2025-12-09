Rails.application.routes.draw do
  devise_for :users
root to: "calendars#index"

resources :users, only:[:edit, :update]
resources :projects do
  resources :project_tasks, only:[:create, :update] do
    patch :sort, on: :collection
  end
end
resources :tasks
resources :habits
end
