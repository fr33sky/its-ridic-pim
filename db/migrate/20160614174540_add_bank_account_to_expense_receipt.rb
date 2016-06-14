class AddBankAccountToExpenseReceipt < ActiveRecord::Migration
  def change
    add_reference :expense_receipts, :bank_account, index: true, foreign_key: true
  end
end
