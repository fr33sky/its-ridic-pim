Rails.application.routes.draw do
  get 'inventory/index'

  resources :adjustments
  resources :adjustment_types
  resources :sales
  resources :payments
  root 'home#index'

  resources :order_items
  resources :products
  resources :orders
  resources :contacts
  resources :inventory, only: [:index]
end
