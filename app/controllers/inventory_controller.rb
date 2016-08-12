class InventoryController < ApplicationController
  def index
    @products = Product.all.order("name")
  end
end
