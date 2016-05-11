class RemoveColumnsFromSales < ActiveRecord::Migration
  def change
    remove_column(:sales, :product_id)
    remove_column(:sales, :user_date)
    remove_column(:sales, :contact_id)
    remove_column(:sales, :sale_price)
  end
end
