class AddAverageCostToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :average_cost, :float
  end
end
