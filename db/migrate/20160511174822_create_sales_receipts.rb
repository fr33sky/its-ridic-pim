class CreateSalesReceipts < ActiveRecord::Migration
  def change
    create_table :sales_receipts do |t|
      t.references :contact, index: true, foreign_key: true
      t.references :payment, index: true, foreign_key: true
      t.datetime :user_date

      t.timestamps null: false
    end
  end
end
