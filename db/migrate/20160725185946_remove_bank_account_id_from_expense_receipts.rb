class RemoveBankAccountIdFromExpenseReceipts < ActiveRecord::Migration
  def change
    if column_exists?(:expense_receipts, :bank_account_id)
      remove_column :expense_receipts, :bank_account_id
    end
  end
end
