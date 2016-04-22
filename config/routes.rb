Rails.application.routes.draw do
  resources :sales
  resources :payments
  root 'home#index'

  resources :order_items
  resources :products
  resources :orders
  resources :contacts
end
