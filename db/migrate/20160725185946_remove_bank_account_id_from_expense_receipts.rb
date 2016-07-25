class RemoveBankAccountIdFromExpenseReceipts < ActiveRecord::Migration
  def change
    remove_column :expense_receipts, :bank_account_id
  end
end
