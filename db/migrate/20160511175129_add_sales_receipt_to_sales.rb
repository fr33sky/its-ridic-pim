class AddSalesReceiptToSales < ActiveRecord::Migration
  def change
    add_reference :sales, :sales_receipt, index: true, foreign_key: true
  end
end
