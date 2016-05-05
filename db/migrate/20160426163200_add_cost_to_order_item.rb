class AddCostToOrderItem < ActiveRecord::Migration
  def change
    add_column :order_items, :cost, :float
  end
end
