Rails.application.routes.draw do
  root to: 'posts#new'
  get 'search', to: 'posts#search'
  post 'make', to: 'posts#make'
  get 'terms', to: 'terms#index', as: :terms
  get 'privacy', to: 'privacies#index', as: :privacy
end
