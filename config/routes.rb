Rails.application.routes.draw do
  devise_for :users
  resources :accounts do
    get :fetch, :on => :collection
  end

  resources :expenses
  resources :expense_receipts
  resources :amazon_statements, only: [:index, :show] do
    get :fetch, :on => :collection
    collection do
      get :authenticate
      get :oauth_callback
    end
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

  resources :products do
    get :fetch, :on => :collection
  end

  resources :orders

  resources :contacts do
    get :fetch, :on => :collection
  end
  resources :inventory, only: [:index]
  resources :configs, only: [:index] do
    collection do
      put :change
    end
  end
end
