Rails.application.routes.draw do
  root 'home#index'

  resources :order_items
  resources :products
  resources :orders
  resources :contacts
end
