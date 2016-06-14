class CreateExpenseReceipts < ActiveRecord::Migration
  def change
    create_table :expense_receipts do |t|
      t.string :description

      t.timestamps null: false
    end
  end
end
