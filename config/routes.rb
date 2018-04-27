Rails.application.routes.draw do
  root to: "wikis#show"
  get 'wiki/:q', to: "wikis#show"
  resources :wikis, only: [:update, :new, :show]
end
