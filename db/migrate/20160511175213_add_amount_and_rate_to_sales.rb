class AddAmountAndRateToSales < ActiveRecord::Migration
  def change
    add_column(:sales, :amount, :decimal)
    add_column(:sales, :rate, :decimal)
  end
end
