class AddProductToSales < ActiveRecord::Migration
  def change
    add_reference :sales, :product, index: true, foreign_key: true
  end
end
