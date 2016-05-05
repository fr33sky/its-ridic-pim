class AddAverageCostToProducts < ActiveRecord::Migration
  def change
    add_column :products, :average_cost, :float
  end
end
