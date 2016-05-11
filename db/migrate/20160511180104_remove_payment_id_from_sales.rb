class RemovePaymentIdFromSales < ActiveRecord::Migration
  def change
    remove_column(:sales, :payment_id)
  end
end
