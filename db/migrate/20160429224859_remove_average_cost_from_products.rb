class RemoveAverageCostFromProducts < ActiveRecord::Migration
  def change
    remove_column :products, :average_cost, :float
  end
end
