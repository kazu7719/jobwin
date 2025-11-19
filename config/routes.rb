Rails.application.routes.draw do
  devise_for :users
root to: "calendars#index"

resources :users, only:[:edit, :update]
end
