Rails.application.routes.draw do
  root to: "wikis#show"
  get 'wiki/:q', to: "wikis#show"
  get 'zh-tw/:q', to: "wikis#show"
  get 'zh-cn/:q', to: "wikis#show"
  get 'zh-hk/:q', to: "wikis#show"
  get 'zh-mo/:q', to: "wikis#show"
  get 'zh-sg/:q', to: "wikis#show"
  resources :wikis, only: [:update, :new, :show]
end
