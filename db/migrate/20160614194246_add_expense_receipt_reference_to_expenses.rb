class AddExpenseReceiptReferenceToExpenses < ActiveRecord::Migration
  def change
    add_reference :expenses, :expense_receipt, index: true, foreign_key: true
  end
end
