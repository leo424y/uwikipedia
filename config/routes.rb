Rails.application.routes.draw do
  root to: "wikis#show"
  get ':lang/wiki/:q', to: "wikis#show"
  resources :wikis, only: [:update, :new, :show]
end
