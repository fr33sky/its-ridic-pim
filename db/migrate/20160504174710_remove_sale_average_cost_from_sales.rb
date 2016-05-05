class RemoveSaleAverageCostFromSales < ActiveRecord::Migration
  def change
    remove_column(:sales, :sale_average_cost, :float)
  end
end
