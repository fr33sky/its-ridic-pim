class AddSaleAverageCostToSales < ActiveRecord::Migration
  def change
    add_column :sales, :sale_average_cost, :float
  end
end
