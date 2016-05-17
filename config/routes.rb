Rails.application.routes.draw do
  resources :amazon_statements, only: [:index, :show] do
    get :fetch, :on => :collection
  end

  resources :sales_receipts
  resources :credentials
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
