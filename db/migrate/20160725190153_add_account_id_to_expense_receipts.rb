class AddAccountIdToExpenseReceipts < ActiveRecord::Migration
  def change
    add_reference :expense_receipts, :account, index: true, foreign_key: true
  end
end
